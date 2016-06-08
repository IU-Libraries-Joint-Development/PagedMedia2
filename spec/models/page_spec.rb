describe FileSet do
  let(:page) {FactoryGirl.create :page}

  describe 'FactoryGirl' do
    describe ':page' do
      it 'is a FileSet' do
        expect(page).to be_a FileSet
      end
      it 'is valid' do
        expect(page).to be_valid
      end
    end
  end

end
