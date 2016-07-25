module PagedMedia::ContainersControllerBehavior
  extend ActiveSupport::Concern
  include Blacklight::Base
  include Blacklight::AccessControls::Catalog

  included do
    class_attribute :presenter_class
    self.presenter_class = PagedMedia::ContainerPresenter
    helper_method :contextual_path
    before_filter :prepend_view_paths
  end


  def prepend_view_paths
    prepend_view_path "app/views/curation_concerns/base"
  end

  def index
    @containers = Container.all
  end

  def show
    # TODO Use table_of_contents instead of @cont_json in partials; for now we share the TOC partial with paged works which needs @cont_json
    @cont_json = container_presenter.table_of_contents
    render locals: { container_presenter: container_presenter }
  end

  private

  def container
    @container ||= Container.find(params[:id])
    # TODO Use container_solr_document when/if cont_array gets solrized, for now load object to get it
    # @container_solr_document ||= ActiveFedora::Base.load_instance_from_solr(params[:id])
  end

  def container_presenter
    @container_presenter ||= presenter_class.new(container, current_ability, request)
  end

  def contextual_path(presenter, parent_presenter)
    ::CurationConcerns::ContextualPath.new(presenter, parent_presenter).show
  end
end