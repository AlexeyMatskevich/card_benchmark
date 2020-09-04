# require 'connection_pool'

require 'click_house'
require 'logger'
DB_NAME = "card_#{ENV["RACK_ENV"]}"
ClickHouse.config do |config|
  config.logger = Logger.new(STDOUT)
  config.adapter = :net_http
  config.database = DB_NAME
  config.url = 'http://clickhouse:8123'
  config.timeout = 60
  config.open_timeout = 3
  config.ssl_verify = false

  # if you use HTTP basic Auth
  config.username = 'default'
end
#
# ClickHouse.connection = ConnectionPool.new(size: 2) do
#   ClickHouse::Connection.new(ClickHouse::Config.new)
# end
