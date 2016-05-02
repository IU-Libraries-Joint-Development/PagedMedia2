# Behaviors for Paged Works
module PagedMedia::PagedWorkBehavior
  extend ActiveSupport::Concern
  include Hydra::Works::WorkBehavior

  included do
    property :creator, predicate: ::RDF::DC.creator, multiple: false
    # property :author, predicate: ::RDF::DC.creator, multiple: false
  end
end
