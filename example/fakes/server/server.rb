require 'sinatra'
require 'json'

module MyMuzikLabelAPI
  class Server < Sinatra::Base

    def calculate_things
       # we're doing some calculation/api calls and such in our 'real' app
       # which we aren't doing in our fake app
      sleep 5
    end

    DB_PATH = "/tmp/ruby_apis_and_clients.fakes"
    post '/song/:name' do |name|
      db = File.open(DB_PATH, "w")
      calculate_things
      db.puts({ name => params[:words] }.to_json); db.flush
      {:status => :ok}.to_json
    end
    get '/song/:name' do |name|
      db = File.open(DB_PATH, "r")
      calculate_things
      words = JSON.parse(db.read)[name]
      {:words => words}.to_json
    end
  end
end

# We use the CLIENT tests, since we will run them twice:
# once against the real server code, and once against the fake server.
# Since we are using client specs to run against the server code, we don't have a test here

class User
  # whatever
end