module APPI
  module RendersExceptions
    extend ActiveSupport::Concern
    def render_appi_exception(exception)
      render json: exception.as_json, status: exception.status.to_sym
    end
  end
end
