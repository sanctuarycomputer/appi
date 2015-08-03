module APPI
  module HandlesResources
    extend ActiveSupport::Concern

    def find_in_params(key, obj=params)
      if obj.respond_to?(:key?) && obj.key?(key)
        found = obj[key]

        if found.is_a?(Hash) && found.has_key?(:data)
          found[:data]
        else
          found
        end
      elsif obj.respond_to?(:each)
        r = nil
        obj.find{ |*a| r=find_in_params(key, a.last) }
        r
      end
    end

    def extract_ids(array)
      result = []
      result = array.map{ |item| item[:id].to_i }.sort if array
      result 
    end

    protected

    def resource
      @resource ||= (@resource = find_resource)
    end

    def find_resource
      if params[:id]
        resource_class.find params[:id]
      elsif params[:slug] 
        # TODO: Make this more friendly aware
        resource_class.friendly.find params[:slug]
      else
        nil
      end
    end

    def resource_class
      controller_name.classify.constantize
    end
    
    def permitted_attributes
      []
    end

    def permitted_relationships
      []
    end
    
    def resource_params
      attributes        = find_in_params(:attributes).try(:permit, permitted_attributes) || {}
      raw_relationships = find_in_params(:relationships) || {}
      relationships     = {}

      raw_relationships.each_key do |key|
        data = raw_relationships.delete(key)[:data]
       
        if permitted_relationships.include?(key.to_sym) && data
          if data.kind_of?(Array)
            relationships["#{key.singularize}_ids"] = extract_ids data
          else
            relationships["#{key}_id"] = data[:id]
          end
        end
      end
      
      attributes.merge relationships
    end
  
  end
end
