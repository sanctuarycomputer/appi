module APPI
  module FiltersResources
    extend ActiveSupport::Concern
    
    protected

    def permitted_filter_params
      []
    end

    def apply_filter_params(collection)
      permitted_filter_params.each do |param|
        if params[param]
          values = params[param].split '|'
          collection = collection.select { |item| values.include? item.try(:status) }
        end
      end
      collection
    end
  
  end
end
