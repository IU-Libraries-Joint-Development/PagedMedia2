require 'rails_helper'

describe 'a container of a paged work' do
  let(:blank_container) {Container.new}
  let(:container) {FactoryGirl.create :container}

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

      # before :all do
      #   container.title = "Chapter One"
      # end

      # after :all do
      #   container.destroy
      # end

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
