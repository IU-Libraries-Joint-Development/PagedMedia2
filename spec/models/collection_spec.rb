describe Collection do
  let(:collection) {FactoryGirl.create :collection}
  let(:complete_collection) {FactoryGirl.create :complete_collection}

  describe 'FactoryGirl' do
    describe ':colllection' do
      it 'is a Collection' do
        expect(collection).to be_a Collection
      end
      it 'is valid' do
        expect(collection).to be_valid
      end
    end
    describe ':complete_collection' do
      it 'is a Collection' do
        expect(complete_collection).to be_a Collection
      end
      it 'is valid' do
        expect(complete_collection).to be_valid
      end
      it 'contains a PagedWork' do
        expect(complete_collection.ordered_members.to_a.first).to be_a PagedWork
      end
    end
  end

end
