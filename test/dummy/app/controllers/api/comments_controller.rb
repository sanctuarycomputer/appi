module Api 
  class CommentsController < ResourceController
    def permitted_attributes 
      [:body]
    end

    def permitted_relationships
      [:post]
    end
  end
end
