module APPI
  module UserTokenController
    extend ActiveSupport::Concern
    
    def token
      user = User.find_by(email: token_params[:email])
      raise APPI::Exception.new("auth.email_does_not_exist", {
        email: token_params[:email]                       
      }) unless user
      
      if user.authenticate token_params[:password]
        token = APPI::TokenUtil.encode({
          id: user.id,
          email: user.email
        })
        render json: { token: token }, status: :ok     
      else
        raise APPI::Exception.new "auth.incorrect_password", email: token_params[:email]
      end
    end

    protected
    def token_params
      raise APPI::Exception.new("auth.bad_request", { attr_name: "email" }) unless params[:email]
      raise APPI::Exception.new("auth.email_is_invalid", { invalid_email: params[:email] }) unless EmailValidator.valid?(params[:email])
      raise APPI::Exception.new("auth.bad_request", { attr_name: "password" }) unless params[:password]
      params.permit :email, :password
    end

  end
end
