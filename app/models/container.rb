class Container < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::PagedMedia::ObjectBehavior
  include ::PagedMedia::ContainerBehavior

  property :title, predicate: ::RDF::Vocab::DC.title, multiple: false do |index|
    index.as :stored_searchable
  end
  validates :title, presence: { message: 'Your work must have a title.' }

  def human_readable_type
    'Container'
  end

end
