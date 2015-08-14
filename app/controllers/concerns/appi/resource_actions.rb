module APPI
  module ResourceActions 
    extend ActiveSupport::Concern
    
    include HandlesResources

    def index
      # The index action also handles requests with slug as a param,
      # like api/posts?slug=true-detective
      if resource
        payload_for resource
      else
        payload_for resource_index
      end
    end

    def show
      payload_for resource
    end

    def create
      payload_for resource_class.create(resource_params)
    end

    def update
      resource.update(resource_params)
      payload_for resource
    end

    def destroy
      resource.destroy!
      head :no_content
    end
    
    # If the controller has APPI::FiltersResources, apply_filter_params.
    # Also doubles as a hook for a developer to write their own filter 
    # logic or scope behaviour for the index collection, such as applying
    # accessible_by(current_ability) as with CanCan.
    def resource_index
      if self.class.included_modules.include? APPI::FiltersResources
        apply_filter_params resource_class.all
      else
        resource_class.all
      end
    end

    def payload_for(object)
      if object.respond_to?(:errors) && object.errors.any?
        raise APPI::Exception.new "resources.validation", { resource_name: controller_name.classify }, object.errors
      else
        render json: object
      end
    end

  end
end
