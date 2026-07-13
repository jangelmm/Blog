class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  # Úsalo como before_action en los controladores donde
  # solo tú (el admin) puedas crear / editar / eliminar.
  def require_login
    return if logged_in?

    redirect_to login_path, alert: "Necesitas iniciar sesión para hacer eso."
  end
end
