require './client'
require 'json'
require 'rack/client'
require 'test/unit'
require 'rack/test'
require 'rack'

## you need to setup and boot up a sandbox server like my-label-development.muzikapi.com, in our case we'll say it's on localhost:9393
class ClientTest < Test::Unit::TestCase

  def setup
    @name = "rock"
    @words = "and all that jazz"
    @client = MyMuzikLabelAPI::Client.new
    @client.domain = "localhost:9393"
  end

  def test_it_stores
    assert_equal @client.post_song("rock", "and all that jazz"), 'ok'
    rescue Errno::ECONNREFUSED
      raise MyMuzikLabelAPI::Client::ServerDown, 'You need to start the sandbox! Run on port 9393. (rackup -p 9393)'       
  end

  def test_it_retreives
    @client.post_song("rock", "and all that jazz")
    assert_equal @client.get_song("rock"), "and all that jazz"
    rescue Errno::ECONNREFUSED
      raise MyMuzikLabelAPI::Client::ServerDown, 'You need to start the sandbox! Run on port 9393. (rackup -p 9393)'       
  end

  # complex tests are hard (slow) in sandbox 
  def test_too_many_songs_will_fail
    # 100.times do
    #   @client.post_song...
    # end
    # make sure delete songs in sandbox becaues it will screw up other tests. Is this even possible??
  end

end