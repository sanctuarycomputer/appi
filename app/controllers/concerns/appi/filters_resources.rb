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
          values = params[param].split('*').map{ |val| YAML.load(val) }
          collection = collection.select { |item| values.include? item.try(param.to_s) }
        end
      end
      collection
    end
  
  end
end
