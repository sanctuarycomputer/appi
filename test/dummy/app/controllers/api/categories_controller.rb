module Api 
  class CategoriesController < ResourceController
    include APPI::FiltersResources

    def permitted_filter_params
      [:name]
    end
  end
end
