PagSeguro.configure do |config|  
  config.email       = Rails.configuration.convinet['pagseguro_email']
  config.token       = Rails.configuration.convinet['pagseguro_token']
  config.environment = Rails.configuration.convinet['pagseguro_environment'].to_sym  
  config.encoding    = 'UTF-8' # ou ISO-8859-1. O padrão é UTF-8.
end