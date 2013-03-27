require './api'
require 'test/unit'

# example testing the fake. still would need to test against the real.
class ClientTestFake < Test::Unit::TestCase
  
  def setup
    @name = "rock"
    @words = "and all that jazz"
    @client = MyMuzikLabelAPI::Client.new
    @server = MyMuzikLabelAPI.fake_app
    @client.mock!(@server)
  end

  def test_it_can_store_and_retreives_a_song
    assert_equal @client.post_song("rock", "and all that jazz"), 'ok'
    assert_equal @client.get_song("rock"), "and all that jazz"
  end
  
end 