require './server'
require 'test/unit'
require 'rack/test'

set :environment, :test

class AppTest < Test::Unit::TestCase

  def app
    MyMuzikLabelAPI::Server
  end
  
  def setup
    @name = "rock"
    @words = "and all that jazz"
    @browser = Rack::Test::Session.new(Rack::MockSession.new(MyMuzikLabelAPI::Server))    
  end
  
  def store_song
    @browser.post "/song/#{@name}", :words => @words
  end

  def test_it_stores
    store_song
    assert @browser.last_response.ok?
    assert_equal "{\"status\":\"ok\"}", @browser.last_response.body
  end

  def test_it_retrieves
    store_song
    @browser.get "/song/#{@name}"
    assert @browser.last_response.ok?
    assert_equal "{\"words\":\"and all that jazz\"}", @browser.last_response.body
  end

end
