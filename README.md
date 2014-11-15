# Experiment: marrying fast unit testing with nesting units below constants tied to Rails

Not sure if this is totally misguided or brilliant. Send comments and PRs! How would you solve this problem? Am I even asking the wrong question?

## The Problem

Imagine this set of files in a Rails application:

```
app/
  models/
    user.rb
    user/
      send_invitation.rb
```

Okay, `User::SendInvitation` is somehow specific to `User` (which makes sense, only Users are being invited to our app), so we place it here instead of, say, `app/invent_something_here/send_invitation_to_user.rb`.

This is very similar to what is described in the book "Growing Rails Applications in Practice". I totally like this approach, because it invites to break things out of a model and provides a place for such aspects. And, we all know naming is hard, but thinking in categories (What is this thing, is is a service? an interaction object? something entriely different?) is even harder, and this approach avoids this alltogether (maybe one could even argue that the categorization problem is entirely artificial).

However, there's a catch.

By naming it `User::SendInvitation`, it's bound to `User`, even if it's a PORO that should be easily unit testable by stubbing `User`.

I have seen many articles that suggest to do the following on top of your unit test:

* define the `User` constant
* require the file that defines `User::SendInvitation`.

This way you can have a lightning-fast unit test for `User::SendInvitation`.

This works. Until this unit test needs to co-exist with other tests that actually load the real `User` class in the same Ruby instance. Then it flies into your face, because you have messed with the framework.

## The <s>solution</s>hack

Two things:

### Avoid requiring/loading the constants at spec load time

```
describe "User::SendInvitation" do
  def self.described_class
    User::SendInvitation
  end
  ...
```

See how this does not use the constant (but instead, its name) as description, fixing this in the next three lines to make rspec's described_class and implicit subject magic possible again.

### Stub nesting constants around each example

If another spec file already happened to load rails, there is really nothing to do: inside the example, we can write `User` and `User::SendInvitation` to trigger autoloading, and maybe stub class methods on `User` should `SendInvitation` call any (RSpec will restore the originals).

Otherwise, make sure a `User` constant exists before `User::SendInvitation` is loaded by stubbing the constant (this is why loading is deferred until example time).

Since after each example, RSpec will remove the stubbed constant, the next such example will need to load `send_invitation.rb` again. Hence we need to use `load` instead of `require`.

## Details

`spec/support/loads_constants.rb` has all the nitty-gritty details.

There is a dummy spec file for `User` and one for `SendInvitation` (both don't do much.)
Both exist twice as exact duplicates to demonstrate that this approach works even with different load orders.

When you run `rake spec`, all possible combinations of the four spec files are used for rspec invocations. Notice the pattern in load time, which is the reason this is done in the first place.

## Got a better way?

Cool, let me know!