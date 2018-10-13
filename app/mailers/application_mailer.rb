class ApplicationMailer < ActionMailer::Base
  default from: = Rails.configuration.convinet['email_notificacoes']
  layout 'mailer'
end
