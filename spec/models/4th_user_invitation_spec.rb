puts "#{__FILE__} loading"

require 'spec_helper'
require 'support/loads_constant'

describe 'User::IssueInvitation' do
  def self.described_class
    eval metadata[:description]
  end

  extend LoadsConstant
  loads_constant 'User::IssueInvitation', from: 'app/models/user'

  it "foo" do
    expect(subject.class.name).to be == 'User::IssueInvitation'
  end
end
