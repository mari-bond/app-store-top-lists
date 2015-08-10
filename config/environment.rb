require "rubygems"
require "bundler"
require 'redis'

Bundler.require(:default)                   # load all the default gems
Bundler.require(Sinatra::Base.environment)  # load all the environment specific gems

require "active_support/deprecation"
require "active_support/all"

$redis = Redis.new