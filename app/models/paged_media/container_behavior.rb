# Behaviours for container model
module PagedMedia::ContainerBehavior
  extend ActiveSupport::Concern

  included do
    self.valid_child_concerns = [Container]
  end

  # List all container titles
  #
  # @return [Array] titles of all pages in container
  def list_titles
    descendents_list_titles
  end

  # Returns nested hash of objects in container
  #
  # @return [Hash] nested hash of page objects in container
  def members_nested
    descendents_tree
  end
end
