# Behaviours for container model
module PagedMedia::ContainerBehavior
  extend ActiveSupport::Concern
  include Hydra::Works::WorkBehavior

  def list_pages
    members = self.members
    member_ids = []
    members.each do |mem|
      member_ids.push mem.id
    end
  end
end
