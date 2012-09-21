# a little shim around Rack::Client that enables passing it a backend. 
# the backend is normally Rack::Client::Handler::NetHTTP
# we'll reset the backend in our tests to route our test requests to our fake/real server code.
require 'ey_api_hmac'
require 'sinatra'

# this is our client and api definitions.
# we'll release our client from here. 
# we'll mount the api portion here in our server.
module MyMuzikLabelAPI

  class Client
    def post_song(name, words)
      JSON.parse(connection.post("http://mymuziklabel.com/song/#{name}", {:words => words}).body)['status']
    end
    def get_song(name)
      JSON.parse(connection.get("http://mymuziklabel.com/song/#{name}").body)['words']
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
      Server.mapper.post_song(name, JSON.parse(env['rack.input'].read)['words']).to_json
    end
    get '/song/:name' do |name|
      Server.mapper.get_song(name).to_json
    end
    class << self
      attr_accessor :mapper
    end
  end

  class FakeMapper
    # compare this side by side to fake_server.rb; this is slimmer because we are sharing more code in Server.
    Store ||= Hash.new
    def self.post_song(name, words)
      Store[name] = words
      {:status => "ok"}
    end
    def self.get_song(name)
      {:words => Store[name]}
    end
  end

  def self.fake_app
    app = MyMuzikLabelAPI::Server
    app.mapper = MyMuzikLabelAPI::FakeMapper
    app
  end

end