# a little shim around Rack::Client that enables passing it a backend. 
# the backend is normally Rack::Client::Handler::NetHTTP
# we'll reset the backend in our tests to route our test requests to our fake/real server code.
require 'ey_api_hmac'
require 'sinatra'

# this is our client and api definitions.
# we'll release our client from here. 
# we'll mount the api portion here in our server.
module MyMuzikLabelAPI

  def self.fake_app
    app = MyMuzikLabelAPI::Server
    app.mapper = MyMuzikLabelAPI::FakeMapper
    app
  end

  class Client
    def post_song(name, words)
      connection.post("http://mymuziklabel.com/song/#{name}", {:words => words}).body
    end
    def get_song(name)
      connection.get("http://mymuziklabel.com/song/#{name}").body
    end
    def mock!(backend)
      connection.backend = backend
    end
    def connection
      @connection ||= EY::ApiHMAC::BaseConnection.new
    end
  end

  class Server < Sinatra::Base
    post '/song/:name' do |name|
      words_from_json = JSON.parse(env['rack.input'].read)['words']
      Server.mapper.post_song(name, words_from_json)
    end
    get '/song/:name' do |name|
      Server.mapper.get_song(name)
    end
    class << self
      attr_accessor :mapper
    end
  end

  class FakeMapper
    # this is slimmer than fake_server.rb
    # compare this side by side to fake_server.rb
    Store ||= Hash.new
    def self.post_song(name, words)
      Store[name] = words
      "ok"
    end
    def self.get_song(name)
      Store[name]
    end
  end
end
