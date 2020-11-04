require "sequel/core"
require "uri"

module Database
  # Delete APP_DATABASE_URL from the environment, so it isn't accidently
  # passed to subprocesses.  APP_DATABASE_URL may contain passwords.
  url = ENV.delete('APP_DATABASE_URL') || ENV.delete('DATABASE_URL') || "postgres://postgres:postgres@localhost:5432"
  url += "/sinatra_#{ENV["RACK_ENV"]}" if url.gsub("postgres://", "").split("/")[1].nil?

  Sequel::Database.extension :pg_json

  URL = url
  URI = URI.parse url

  DB_NAME = URI.path[1..-1]
end
