require 'spec_helper'

describe 'User::IssueInvitation' do
  def described_class
    User::IssueInvitation
  end

  before do
    stub_const 'User', Module.new

    require_relative '../../../app/models/user/issue_invitation'
  end

  it "foo" do
    expect(subject.class.name).to be == 'User::IssueInvitation'
  end
end

