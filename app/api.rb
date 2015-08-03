require 'sinatra'

class Api < Sinatra::Base
  main_path = %r{/categories/(\d+)/apps/(paid|free|grossing)}

  get %r{^#{main_path}$} do |category_id, monetization|

  end

  get %r{^#{main_path}/(\d+)$} do |category_id, monetization, rank|

  end

  get %r{^#{main_path}/publishers$} do |category_id, monetization|

  end
end