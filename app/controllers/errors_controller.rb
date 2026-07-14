class ErrorsController < ApplicationController
  # No requerimos inicio de sesión para ver los errores
  skip_before_action :require_login, raise: false

  def not_found
    render status: :not_found
  end

  def internal_server_error
    render status: :internal_server_error
  end
end
