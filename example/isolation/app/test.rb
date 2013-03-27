require './cool_musicians_app'
require 'fakeweb'
require 'json'
require 'rack'
require 'rack/client'
require 'test/unit'
require 'rack/test'

class SocialMusicUploaderTest < Test::Unit::TestCase

  def setup
    @name = "funky"
    @words = "james brown is da bomb!"
    @muzik_label_client = MyMuzikLabelAPI::Client.new
    @muzik_label_client.domain = "mymuziklabel.localdev.com" 
    # we need to mock out the server here, if we end up changing our api ../server/server this test will still pass 
    # and our cool social app using our record labeling company won't have broken tests even though the upload is not working
    FakeWeb.register_uri(:post, "http://mymuziklabel.localdev.com/song/#{@name}", :body => {:status => "ok"}.to_json)
    FakeWeb.register_uri(:get, "http://mymuziklabel.localdev.com/song/#{@name}", :body => {:words => @words}.to_json )
  end

  def test_it_uploads_to_muzik_label_through_our_interface
    SocialMusicUploader.upload_song_to_muzik_label(@name, @words)
    assert_equal @muzik_label_client.get_song(@name), @words
  end

end