require './api.rb'
require 'sinatra'
require 'rack'


class MyMuzikLabel # A representation of a rails app

  # models
  class User; def self.has_too_many_songs?; false; end; end
  # controllers
  class Application < Sinatra::Base
    get '/' do; 'main server application where we are going to mount the external api we created.';  end
  end
   
  
  
  # our mapper: we can access all our server logic from within here that we didn't have access to in the api
  module MuzikMapper
    def self.post_song(name, words)
      unless User.has_too_many_songs?
        {:status => "ok"} # Song.create(:words => words, :name => name)
      end
    end
    def self.get_song(name)
      {:words => 'and all that jazz'} # {:words => Song.where(:name => name).words }
    end
  end
  


  # compare this to MyMuzikLabelAPI.fake_app which just uses the fake mapper instead.
  def self.app
    app = Rack::Cascade.new([MyMuzikLabelAPI::Server, MyMuzikLabel::Application])
    MyMuzikLabelAPI::Server.mapper = MyMuzikLabel::MuzikMapper
    app
  end
end