require './api.rb'
require 'sinatra'
require 'rack'

# our kinda Rails application thingie
class MyMuzikLabel
  # models
  class User
    def self.has_too_many_songs?
      false
    end
  end

  # controllers
  class Application < Sinatra::Base
    get '/' do
      'main server application where we are going to mount the api we created.'
    end
  end

  # our mapper
  # we can access all our server logic from within here that we didn't have access to in the api
  module MuzikMapper
    def self.post_song(name, words)
      unless User.has_too_many_songs?
        # Song.create(:words s=> words, :name => name)
        {:status => "ok"}
      end
    end
    def self.get_song(name)
      {:words => 'and all that jazz'} # {:words => Song.where(:name => name).words }
    end
  end

  def self.app
    app = Rack::Cascade.new([MyMuzikLabelAPI::Server, MyMuzikLabel::Application])
    MyMuzikLabelAPI::Server.mapper = MyMuzikLabel::MuzikMapper
    app
  end
end

# we don't need to test this explicitly because api_tests cover this stuff.

#config.ru:
# run MyMuzikLabel.app