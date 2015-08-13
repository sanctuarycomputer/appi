module Api 
  class PostsController < ResourceController
    include APPI::FiltersResources

    def permitted_attributes 
      [:title, :body]
    end

    def permitted_relationships
      [:comments]
    end

    def permitted_filter_params
      [:published]
    end
  end
end
