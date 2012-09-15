require 'sinatra'
require 'json'

module MyMuzikLabelAPI
  class Server < Sinatra::Base
    
    DB_PATH = "/tmp/ruby_apis_and_clients.isolation"

    post '/song/:name' do |name|
      db = File.open(DB_PATH, "w")
      db.puts({ name => params[:words] }.to_json); db.flush
      {:status => :ok}.to_json
    end

    get '/song/:name' do |name|
      db = File.open(DB_PATH, "r")
      words = JSON.parse(db.read)[name]
      {:words => words}.to_json
    end
  end
end

class User
  # whatever
end