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
    @muzik_label_client.mock! # this is the sweet part
  end

  def test_it_uploads_to_muzik_label_through_our_interface
    SocialMusicUploader.upload_song_to_muzik_label(@name, @words)
    assert_equal @muzik_label_client.get_song(@name), @words
  end

end