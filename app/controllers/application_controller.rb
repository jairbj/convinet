class ApplicationController < ActionController::Base
  include FlashMessageHelper

  def after_sign_in_path_for(_resource)
    root_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end
end
