SparkPostRails.configure do |c|
  c.api_key = Rails.configuration.convinet['sparkpost_api_key']
   c.html_content_only = true
end