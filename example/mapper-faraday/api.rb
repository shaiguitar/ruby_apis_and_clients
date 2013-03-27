require 'sinatra'
require 'rack'
require 'faraday'
require 'json'

# This is a copy over from the mapper pattern example in mapper/ using rack client. This demonstrates using faraday instead of rack-client.
# Here I demonstrate using faraday with a fake app, but obviously the same holds for using this against real app (MyMuzikLabel.app) as well.

module MyMuzikLabelAPI

  class Client
    # this is the change using faraday, it's a faraday compatible way of redirecting to a rack app (which we use as our fake).
    def mock!(backend)
      @connection = Faraday.new(:url => 'http://mymuziklabel.com') do |faraday|
        faraday.adapter :rack, backend
      end
    end
    def post_song(name, words)
      JSON.parse(@connection.post("/song/#{name}", {:words => words}.to_json).body)['status']
    end
    def get_song(name)
      JSON.parse(@connection.get("/song/#{name}").body)['words']
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