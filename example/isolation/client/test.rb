require './client'
require 'fakeweb'
require 'json'
require 'rack'
require 'rack/client'
require 'test/unit'
require 'rack/test'

class Client < Test::Unit::TestCase

  def setup
    @name = "rock"
    @words = "and all that jazz"
    @client = MyMuzikLabelAPI::Client.new
    @client.domain = 'mymuziklabel.localdev.com'
    
    # mimic the server :(
    FakeWeb.register_uri(:post, "http://mymuziklabel.localdev.com/song/#{@name}", :body => {:status => "ok"}.to_json)
    FakeWeb.register_uri(:get, "http://mymuziklabel.localdev.com/song/#{@name}", :body => {:words => @words}.to_json )
  end

  def test_it_can_store_and_retreives_a_song
    assert_equal "ok", @client.post_song(@name, @words)
    assert_equal @words, @client.get_song(@name)
  end

end