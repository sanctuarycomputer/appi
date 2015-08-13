module APPI
  module HandlesResources
    extend ActiveSupport::Concern

    # Finds a key in a hash (defaults to using the controllers params hash).
    #
    # Params:
    # +key+:: +Symbol+ A symbol representing the key you'd like to find.
    # +obj+:: +Hash+ An object to serach for the key within.
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

    # Resolves the Class for a type.
    #
    # Params:
    # +type+:: +String+ A stringified type.
    # +singular+:: +Boolean+ Pass true if you don't want to singularize the type. 
    def klass_for_type(type, singular=false)
      type = type.singularize unless singular
      type.classify.constantize
    end
    
    # Takes an array of type / id Hashes (as per the JSONAPI spec) and returns an array
    # of numerical IDs.  Also accepts Friendly ID slugs as the ID, provided the model is
    # using the :finders feature.
    #
    # Params:
    # +array+:: +Array+ Array of objects with type/id pairs, as per the JSONAPI Spec
    def extract_ids(array)
      array = [] unless array
      array.map{ |item| extract_id item }
    end

    # Extracts the numerical ID from a JSONAPI style type / id payload.  If the ID is
    # not numerical, it will attempt to resolve the ID to a model by issuing a find
    # on it's class (gathered from the type also in the hash).  If it can't find a 
    # Class or Model of the payload, it will just return the original ID.  Useful when
    # using the :finders feature of Friendly ID.
    #
    # Params:
    # +hash+:: +Hash+ Hash with type/id pair, as per the JSONAPI Spec
    def extract_id(hash)
      passed_id = hash[:id]
      if passed_id.to_i > 0
        passed_id.to_i
      else
        begin
          klass = klass_for_type hash[:type]
          model = klass.find passed_id
          model.id
        rescue
          passed_id
        end
      end
    end

    private 

    # Loads the resource into an instance variable if it is not already present.
    def resource
      @resource ||= (@resource = find_resource)
    end

    # Will find the resource for a controller using params[:id] or params[:slug]
    # in that order, provided they're present.
    def find_resource
      if params[:id]
        resource_class.find params[:id]
      elsif params[:slug] 
        resource_class.find params[:slug]
      else
        nil
      end
    end
    
    # Resolves the resource class from the controller name.
    def resource_class
      controller_name.classify.constantize
    end
    
    # An array of permitted attributes for the controller to whitelist in the resource_params.
    def permitted_attributes
      []
    end

    # An array of permitted relationships for the controller to whitelist in the resource_params.
    def permitted_relationships
      []
    end
    
    # Builds a whitelisted resource_params hash from the permitted_attributes & 
    # permitted_relationships arrays.  Will automatically attempt to resolve 
    # string IDs to numerical IDs, in the case the model's slug was passed to 
    # the controller as ID.
    def resource_params
      attributes    = find_in_params(:attributes).try(:permit, permitted_attributes) || {}
      relationships = {}
      
      # Build Relationships Data
      relationships_in_payload = find_in_params(:relationships)
      if relationships_in_payload
        raw_relationships = relationships_in_payload.clone

        raw_relationships.each_key do |key|
          data = raw_relationships.delete(key)[:data]
        
          if permitted_relationships.include?(key.to_sym) && data
            if data.kind_of?(Array)
              relationships["#{key.singularize}_ids"] = extract_ids data
            else
              relationships["#{key}_id"] = extract_id data
            end
          end
        end
      end
      
      attributes.merge relationships
    end
  end
end
