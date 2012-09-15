require 'sinatra'
require 'json'

module MyMuzikLabelAPI
  class FakeServer < Sinatra::Base
    Store = Hash.new
    post '/song/:name' do |name|
      Store[name] = params[:words]
      {:status => :ok}.to_json
    end
    get '/song/:name' do |name|
      {:words => Store[name]}.to_json
    end
  end
end