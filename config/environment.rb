require "rubygems"
require "bundler"
require 'redis'

Bundler.require(:default)                   # load all the default gems
Bundler.require(Sinatra::Base.environment)  # load all the environment specific gems

require "active_support/deprecation"
require "active_support/all"

if ENV["REDISTOGO_URL"]
  redis_uri = URI.parse(ENV["REDISTOGO_URL"])
  options = {:host => redis_uri.host, :port => redis_uri.port, :password => redis_uri.password}
else
  options = {}
end
$redis = Redis.new(options)
