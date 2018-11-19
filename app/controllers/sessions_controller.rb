class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, on: :create

  def new
    redirect_to root_path, alert: 'You are already logged in.' if Current.authorization
  end

  def create
    auth_hash = request.env['omniauth.auth']
    @auth = Authorization.from_omniauth(auth_hash)

    if @auth
      sign_in_and_redirect @auth
    else
      info = auth_hash['info']
      @user = User.where(email: info['email']).first
      @user ||= User.new name: info['name'], email: info['email']

      @auth = @user.authorizations.build provider: auth_hash['provider'], uid: auth_hash['uid']
      @user.save

      Integration.notify_all :user_signed_in, authorization_id: @auth.id.to_s
      sign_in_and_redirect @auth
    end
  end

  def failure
    redirect_to login_path,
                alert: 'You need to allow access to your account! This will only give us access to your name and email.'
  end

  def destroy
    session[:authorization_id] = nil
    redirect_to root_path, notice: 'Signed out.'
  end

  private

  def sign_in_and_redirect(authorization)
    session[:authorization_id] = authorization.id
    redirect_to root_path
  end
end
