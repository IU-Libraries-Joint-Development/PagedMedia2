# Generated via
#  `rails generate curation_concerns:work PagedWork`
describe PagedWork do
  let(:paged_work) {FactoryGirl.create :paged_work}
  let(:complete_paged_work) {FactoryGirl.create :complete_paged_work}

  describe 'FactoryGirl' do
    describe ':paged_work' do
      it 'is a PagedWork' do
        expect(complete_paged_work).to be_a PagedWork
      end
      it 'is valid' do
        expect(complete_paged_work).to be_valid
      end
    end
    describe ':complete_paged_work' do
      it 'is a PagedWork' do
        expect(complete_paged_work).to be_a PagedWork
      end
      it 'is valid' do
        expect(complete_paged_work).to be_valid
      end
      it 'contains 2 Containers, 1 FileSet' do
        expect(complete_paged_work.ordered_members.to_a.map(&:class)).to eq [Container, Container, FileSet]
      end
    end
  end

  it "should be saved to Fedora" do
    # This will attempt to use Fedora and will fail if not available during tests
    expect(paged_work.save).to be true
  end
end
