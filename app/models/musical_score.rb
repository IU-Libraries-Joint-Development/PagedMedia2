# Generated via
#  `rails generate curation_concerns:work MusicalScore`
class MusicalScore < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include ::PagedMedia::ObjectBehavior
  include ::PagedMedia::ContainerBehavior

  validates :title, presence: { message: 'Your work must have a title.' }
end
