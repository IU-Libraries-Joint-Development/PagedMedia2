describe FileSet do
  let(:user) {FactoryGirl.create :user}

  describe 'FactoryGirl' do
    describe ':user' do
      it 'is a User' do
        expect(user).to be_a User
      end
      it 'is valid' do
        expect(user).to be_valid
      end
    end
  end

end
