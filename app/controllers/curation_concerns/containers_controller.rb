class CurationConcerns::ContainersController < ApplicationController
  include CurationConcerns::CurationConcernController
  #include PagedMedia::ContainersControllerBehavior
  self.curation_concern_type = Container
end