# Generated via
#  `rails generate curation_concerns:work PagedWork`
require 'rails_helper'

describe PagedWork do
  let(:paged_work) {FactoryGirl.create :paged_work}

  it "should be saved to Fedora" do
    # This will attempt to use Fedora and will fail if not available during tests
    expect(paged_work.save).to be true
  end
end
