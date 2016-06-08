describe 'a container of a paged work' do
  let(:blank_container) {Container.new}
  let(:container) {FactoryGirl.create :container}
  let(:contained_page) {FactoryGirl.create :contained_page}

  describe 'FactoryGirl' do
    describe ':container' do
      it 'is a container' do
        expect(container).to be_a Container
      end
      it 'is valid' do
        expect(container).to be_valid
      end
    end
    describe ':contained_page' do
      it 'is a container' do
        expect(contained_page).to be_a Container
      end
      it 'is valid' do
        expect(contained_page).to be_valid
      end
      it 'contains a page' do
        expect(contained_page.ordered_members.to_a.first).to be_a FileSet
      end
    end
  end

  it 'has a title' do
    expect(blank_container).to respond_to(:title)
  end

  context 'when it is saved' do
    context 'without required attributes' do

      it 'should fail to save' do
        expect(blank_container.save).to be false
      end

    end

    context 'with attributes' do
      subject do
        Container.new title: 'Chapter One'
      end

      it 'should be valid' do
        expect(container.save).to be true
      end

      describe 'the solr fields of a container'
      it 'has a title field' do
        expect(container.to_solr.keys).to include(Solrizer.solr_name('title', :stored_searchable))
      end
    end
  end

end
