module APPI
  module CurrentUser
    extend ActiveSupport::Concern

    protected

    def current_user
      @current_user ||= set_current_user
    end

    def set_current_user
      if request_token
        @current_user = User.find requester_params[:id]
      else
        @current_user = User.new
      end
    end

    def request_token
      auth_header = headers['Authorization'] || env['HTTP_AUTHORIZATION']
      
      if auth_header.present?
        return auth_header.split.last
      else
        nil
      end
    end

    def requester_params
      APPI::TokenUtil.decode(request_token) if request_token
    end
  end
end
