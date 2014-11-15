puts "#{__FILE__} loading"

require 'rails_helper'

describe User do
  it "foo" do
    expect(subject.class.name).to be == 'User'
  end
end
