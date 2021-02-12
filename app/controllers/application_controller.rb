class ApplicationController < ActionController::API
  before_action :authenticate, except: [:healthcheck]

  def healthcheck
    render json: {success: true}
  end

  private

  def authenticate
    @account = ::AuthenticationUtil.authenticate(
      username: request.headers["username"],
      password: request.headers["password"]
    )
    render status: 403 unless @account
  end
end
