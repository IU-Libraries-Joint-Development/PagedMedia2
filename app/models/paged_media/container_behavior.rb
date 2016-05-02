# Behaviours for container model
module PagedMedia::ContainerBehavior
  extend ActiveSupport::Concern
  include Hydra::Works::WorkBehavior

  def list_titles
    members = self.members
    member_titles = []
    members.each do |mem|
      if mem.is_a?(Container)
        member_titles.push [mem.title => mem.list_titles]
      else
        member_titles.push mem.title
      end
    end
    member_titles
  end

  def members_nested
    members = self.members
    member_ids = []
    members.each do |mem|
      if mem.is_a?(Container)
        member_ids.push [mem => mem.members_nested]
      else
        member_ids.push mem
      end
    end
    member_ids
  end
end
