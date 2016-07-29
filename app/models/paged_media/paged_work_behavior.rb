# Behaviors for Paged Works
module PagedMedia::PagedWorkBehavior
  extend ActiveSupport::Concern
  #include Hydra::Works::WorkBehavior

  included do
    self.valid_child_concerns = [Container]
    property :creator, predicate: ::RDF::DC.creator, multiple: true
    #property :author, predicate: ::RDF::DC.creator, multiple: false
  end

  # @param [IO] file The page content to add
  # @param [Hash] args options: :title
  def add_page(file, *args)
    fs = FileSet.new
    fs.apply_depositor_metadata args[:user] || User.current_user.email
    p = fs.add_file file
  end

end
