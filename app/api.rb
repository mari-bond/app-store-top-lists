require 'sinatra'
require "sinatra/json"
require "./config/environment"
require_relative 'services/apps_fetcher'

class Api < Sinatra::Base
  main_path = %r{/categories/(\d+)/apps/(paid|free|grossing)}

  get %r{^#{main_path}$} do |category_id, monetization|
    json AppsFetcher.new(category_id, monetization).fetch_top
  end

  get %r{^#{main_path}/(\d+)$} do |category_id, monetization, rank|
    json AppsFetcher.new(category_id, monetization).top_by_rank(rank)
  end

  get %r{^#{main_path}/publishers$} do |category_id, monetization|
    json AppsFetcher.new(category_id, monetization).fetch_publishers
  end
end