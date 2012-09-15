require './client'
require 'json'
require 'rack/client'
require 'test/unit'
require 'rack/test'
require 'rack'
require 'realweb'

# ASSERTIONS
module ClientTests
  def test_it_can_store_and_retreives_a_song
    assert_equal @client.post_song("rock", "and all that jazz"), 'ok'
    assert_equal @client.get_song("rock"), "and all that jazz"
  end
end

# run against fake or real.
# in our CI server we would ensure to run in both modes. 
# in doing that, we're validating that our fake mirrors the server behavior.
if ENV['USE_REAL']  
  # run against 'real' server
   class ClientTestReal < Test::Unit::TestCase
     def setup
       @name = "rock"
       @words = "and all that jazz"
       @server = RealWeb.start_server("../server/config.ru")
       @client = MyMuzikLabelAPI::Client.new
       @client.domain = "http://#{@server.host}:#{@server.port}"
     end
     def teardown
       @server.stop
     end

     include ClientTests
   end
else
  # run against 'fake' server
  class ClientTestFake < Test::Unit::TestCase
    def setup
      @name = "rock"
      @words = "and all that jazz"
      @server = RealWeb.start_server("fake_server_config.ru")
      @client = MyMuzikLabelAPI::Client.new
      @client.domain = "http://#{@server.host}:#{@server.port}"
    end
    def teardown
      @server.stop
    end

    include ClientTests
  end 
end