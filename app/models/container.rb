class Container < ActiveFedora::Base
  include ::PagedMedia::ContainerBehavior

  property :title, predicate: ::RDF::Vocab::DC.title, multiple: false do |index|
    index.as :stored_searchable
  end
  validates :title, presence: { message: 'Your work must have a title.' }

end
