class ApplicationController < ActionController::Base
  before_action :initialize_cart
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_dashboard_path
    else
      super
    end
  end

  private

  def initialize_cart
    session[:cart] ||= []
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nom, :autre_info])
  end
end
