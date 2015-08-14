class ApplicationController < ActionController::Base
  include APPI::RendersExceptions

  rescue_from Exception do |exception|
    case exception
    when APPI::Exception
      render_appi_exception exception 
    else
      details = {
        subclass: exception.class.to_s,
        message:  exception.message
      }
      render_appi_exception APPI::Exception.new('appi.generic_exception', details)
    end
  end

  def render_nothing
    render head: :ok
  end
end
