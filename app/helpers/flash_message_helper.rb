module FlashMessageHelper
  def flash_errors(resource)
    if resource.errors.any?
      errors = ''
      resource.errors.messages.each do |msg|
        msg[1].each do |erro|
          errors << "#{msg[0].to_s.capitalize} - #{erro} <br />"
        end
      end
      flash[:danger] = errors.html_safe
    end
  end
end