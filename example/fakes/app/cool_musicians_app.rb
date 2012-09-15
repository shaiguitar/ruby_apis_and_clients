# FAKES
# now that we have the fake_app.rb we can ship that fake with the client
# I can just call it out, and the client will be using the fake server, which we know (by running our tests in both modes) mimics our real server.
# For more on that approach see Andy Delcambre's "toggable mock" talk on vimeo.
# 
# class CoolMusicianApp
# 
#   def test_thing
#     rocker = Musician.new
#     title, words = rocker.make_awesome_song!
#     @client = MyMuzikLabelAPI::Client.new
#     @client.mock!
#     @client.post_song(title, words)
#     assert_equal @client.get_song(title), words
#   end
# 
# end
