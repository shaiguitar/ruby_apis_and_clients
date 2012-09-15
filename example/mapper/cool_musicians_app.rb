# MAPPER
# 
# integration endpoint from the app including the client all the way back to our server
#
### We can route the requests we make in tests via the rack_builder in our tests, per domain. Very cool:
# rack_builder = Rack::Builder.app do
#    # third party app
#   map "http://musiciansthirdpartyapp.com/" do
#     run MusiciansThirdPartyApp
#   end
#   # this is the server we're going to interact with
#   map "http://mymuziklabel.com/" do
#     run MyMuzikLabelAPI::FakeMapper.fake_app
#   end
#   # anything else
#   map "http://whatever.else.com/" do
#     run Rack::Client::Handler::NetHTTP
#   end
# end
# 
# @client = MyMuzikLabelAPI::Client.new
# @client.mock!(rack_builder)
# 
### Then we can use the client (which is using mymuziklabel.com, thus routing to MyMuzikLabelAPI::FakeMapper.fake_app)
# module MusiciansThirdPartyApp
#   class Server < Sinatra::Base
#     post '/funky' do |words|
#       @client.post_song('funky', words)
#       'song successfully posted'
#     end 
#   end
# end
#  
# visit MusiciansThirdPartyApp.domain
# fill_in "write a song", :with => "james brown"
# click "Upload funky song to MyMuzikLabel"
# response should say "song successfully posted"
#
# @client.get_song('funky').should eq "james brown" # this is hitting our fake_mapper, which we know is validated against our real (both modes).