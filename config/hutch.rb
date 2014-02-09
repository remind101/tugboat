require 'uri'

if url = ENV['RABBITMQ_URL']
  uri = URI.parse(url)

  Hutch::Config.mq_host = uri.host
  Hutch::Config.mq_username = uri.user
  Hutch::Config.mq_password = uri.password
  Hutch::Config.mq_vhost = uri.path.gsub(/^\//, '')
end

if url = ENV['RABBITMQ_MANAGEMENT_URL']
  uri = URI.parse(url)

  Hutch::Config.mq_api_host = uri.host
  Hutch::Config.mq_api_port = uri.port || uri.scheme == 'https' ? 443 : 80
  Hutch::Config.mq_api_ssl  = uri.scheme == 'https'
end

Hutch::Logging.logger = Shipr.logger
Hutch.connect
