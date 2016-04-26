module PagedMedia::PagedWorkBehavior
  extend ActiveSupport::Concern
  include Hydra::Works::WorkBehavior

  included do
    property :author, predicate: ::RDF::DC.creator, multiple: false
  end
end
