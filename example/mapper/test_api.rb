require './api'
require './server'
require 'json'
require 'rack'
require 'rack/client'
require 'test/unit'
require 'rack/test'

# ASSERTIONS
module ClientTests
  def test_it_can_store_and_retreives_a_song
    assert_equal @client.post_song("rock", "and all that jazz"), 'ok'
    assert_equal @client.get_song("rock"), "and all that jazz"
  end
end

# same idea as fake (use both real and fake) to validate the fake and real
if ENV['USE_REAL']  
  # run against 'real' server
   class ClientTestReal < Test::Unit::TestCase
     def setup
       @name = "rock"
       @words = "and all that jazz"
       @client = MyMuzikLabelAPI::Client.new
       @server = MyMuzikLabel.app # real
       @client.mock!(@server)
     end

     include ClientTests
   end
else
  # run against 'fake' server
  class ClientTestFake < Test::Unit::TestCase
    def setup
      @name = "rock"
      @words = "and all that jazz"
      @client = MyMuzikLabelAPI::Client.new
      @server = MyMuzikLabelAPI.fake_app # fake
      @client.mock!(@server)
    end

    include ClientTests
  end 
end