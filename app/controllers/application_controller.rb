class ApplicationController < ActionController::Base
  include FlashMessageHelper

  def after_sign_in_path_for(_resource)
    root_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    if current_admin_user
      admin_usuario_path(@return_usuario)
    else
      root_path
    end
  end
end
