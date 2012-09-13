!SLIDE 
# Approaches for testing http ruby based apis and client libs #

So, every good slide deck says you need to tell a story; here's mine:

!SLIDE

// picture of music labeling company of some sort?

You are a record labeling company, you've been told such buzzwords such as 'cloud', 'everything as a service' and that you need to start getting into the internet game. You decide to transfer your musicians music to your online store, and build an api and consumer library so your musician customers and other aspiring musicians can post and save their music there which you'll later resell.

!SLIDE
# Talk is about #

Just to be clearer on my intent:

Testing APIs can be tough if you take testing client libs as well into consideration as one unit you develop. There are a fair amount of approaches  testing server apis, client apis and the various tradeoffs of spec runtime, maintainability, ease to get up and running, slimmer code etc. I'll also introduce what some called the mapper pattern, an approach that has been used at Engine Yard for designing APIs.
// In a way this can also be seen partly as some tradeoffs and limitations of a full setup-teardown you need to do get running in order to do a full test suite.

!SLIDE bullets incremental
# Available Patterns: #

// GET DETAILS FROM 02_INFO.MD HAS A LIST OF BAD-GOOD STUFF IN THESE...
// move this quickly, just to give a taste of what's ahead.

- No testing (00)
  
Awesome. Simple and best, right? No, but seriously. We're not going here - you want to test, so actually, some approaches that exist are:
  
- Simple Client/Server. (0)

Isolation: no cross validation in tests. You mock out server responses completely in client, and test server behavior in the server. 
There's no link between the two, bad integration.

- Validation across systems. "Sandbox" testing. (1)

This is better, you actually hit up a real live server running your code. However, there are no fixtures, and has the disadvantage that you can't reset the state of the external server you are using (for eg the server doesn't support doing those types of tests via an accessible api, or reset the data). 

- Fake Servers. (2)

This is good because faster specs, server code confidential, eliminates duplication between server and client specs. Integration still goes the whole way through. But, you need to maintain an entire fake codebase which can grow bigger than other approaches. You run client twice, so the real validates the fake.

- Mapper pattern; Client and Server in own repo, have mapper patter inside real server. (3)

This is a full integration test path, but you need to understand the mapper pattern which isn't widely known.

!SLIDE
# Back to story #

So you decide to create an API musicians and client library that musicians can use to post music. Plan is so they'll use the client lib in their own applications thus bringing your record label to fame, scale and just a general all time winning status.

The design is:

POST /song/:name, :body => 'words of song'
GET  /song/:name # returns the song

In order to do this, the end result will need to look something like:

- The http api in your MyMuzikLabel rails app.
- A good robust client lib you'll expose for your musician consumers, with something like the following interface: 

<pre>
  MyMuzikLabelAPI::Client.post_song("rock", "this will rock the world")
  MyMuzikLabelAPI::Client.get_song("rock")
</pre>

You start coding the API you'll use in your app.

<pre>
  module MyMuzikLabelAPI
    class Server < Sinatra::Base
    Store = Hash.new
    post '/song/:name' do
      Store[name] = request.body.read
      # maybe do some complex looking up if a song with a similar date is in your db or smth
    end
    get '/song/:name' do
      Store[name].to_json
    end
  end
  
  ## test server
  
  Rack::Client.post('/song/rock', "this will rock the world")
  Rack::Client.get('/song/rock').body.readlines.should == "this will rock the world"
  
  ## Build client
  
  module MyMuzikLabelAPI
    class Client
      def post_song(name, words)
        Rack::Client.post("/song/#{name}", words)
      end
      def get_song(name)
        Rack::Client.get("/song/#{name}").body.readlines
      end
    end
  end
  
  ## test client 
  
  # ...mock out server with something like FakeWeb or mocks etc.
</pre>
  
The problem here is that there's no test path between the client and server - there's no integration done, so if we decided to change the public api,  the client tests would still pass. (lets say we wanted to add authentication to post a song via a song_id /song/:name/:auth_key). We would change one thing, and the other tests would still pass. No good.

!SLIDE
# Sandboxes #

So we decide to move ahead and use a Sandbox for testing. We spin up our main rails app, keep that running and use that to run our client against it.

<pre>
  module MyMuzikLabelAPI
    class Server < Sinatra::Base
      #...
    end
  end

  ## test our server with the client we'll create
  
  MyMuzikLabelAPI::Client.post_song("rock", "this will rock the world")
  MyMuzikLabelAPI::Client.get_song("rock").should == "this will rock the world"
  
  ## Build client
  
  module MyMuzikLabelAPI
    class Client
      #...
    end
  end
  
  ## test client 
  
  # we do not mock anything out, we directly use the sandbox testing server we spun up.
</pre>

This works fairly well; if we decide to break or change our public api, our client and server tests will fail. However:

Firstly, with sandboxes there's the obvious disadvantage of needing to set it up, maintain it's environment, dependencies etc. Just getting down to coding is blocked due to the overhead of setting up the sandbox.

More importantly, if our musician consumers wanted to use the client library in an application they were building (which is the point of the client!) there would be no fakes or fixtures for them to use shipped with the client.

  #jacob
  
Client Complex tests are problematic - if we needed to check for a musician who uploaded too many songs: we don't have access to server functionality that we can use in the client that isn't exposed in the api (user actions). We would need to mock that behavior out in client tests, which breaks the integration path. Even if we did have an api for that we could use in the client, we'd still need to setup and teardown in our tests for that to set the sandbox server to the right state, which is not a lot, but is overhead.

!SLIDE
# In-memory & Fake servers #

We could use realweb[1], or something like it, to boot the server in memory and not need to handle with setup/teardown of server state for complex tests, or setting up and maintaining the sandbox. 

<pre>
  module MyMuzikLabelAPI
    class Server < Sinatra::Base
      #...
    end
  end

  ## test our server with the _CLIENT SPECS_
  
  ## Build client
  
  module MyMuzikLabelAPI
    class Client
      def post_song(name, words)
        Rack::Client.post("/song/#{name}", words)
      end
      def get_song(name)
        Rack::Client.get("/song/#{name}").body.readlines
      end
    end
  end
    
  module MyMuzikLabelAPIFake
    class Client
      # ...
    end
  end
  
  ## client specs

  # we end up running the specs against our fake AND our real. this enables us to have a fake that we can expose to customers 
  # and is validated by the fact that our specs pass on the real.
</pre>

This is full integration, this is good. Some noticeable advantages are that we

1) Have a robust client lib, with a fake server that can be used in third party applications for their own tests.
2) Server code confidential.
3) Eliminates duplication between server and client specs.
4) Faster specs.

This is pretty good. 

However (!), there are some bad things here:

1) More steps in making a code change (releasing is harder).
2) You need to maintain an entire fake codebase which can grow bigger than other approaches.

!SLIDE
# Mapper style #

SO! It's the last one, I promise ;)

  #jacob

You take a different approach and code the server, client and fake all in one repo, and tie it into your rails app at the end:

<pre>
  
  ## Mapper in one repo
  
  module MyMuzikLabelAPI
    class Client
      def self.post_song(name, words)
        # connection is a rack-client object which will send to the Server.
        connection.post("http://mymuziklabel.localdev.engineyard.com/song/#{name}", {:words => words})
      end
      def self.get_song(name)
        # connection is a rack-client object which will send to the Server.
        connection.get("http://mymuziklabel.localdev.engineyard.com/song/#{name}")
      end
      def self.mock!(backend)
        connection.backend = backend
      end
      def self.connection
        @connection ||= EY::ApiHMAC::BaseConnection.new
      end
    end
    class Server < Sinatra::Base
      post '/song/:name' do
        Server.mapper.post_song(name, params[:words])
      end
      get '/song/:name' do
        Server.mapper.get_song(name)
      end
      class << self
        attr_accessor :mapper
      end
    end
    class Fake
    end
  end
  
  ## In your main rails app:
  
  # routes.rb
  MyMuzikLabel::Application.routes.draw do
    mount MyMuzikLabelAPI::Server.server, :at => "/api"
  end

  #mapper setup in an initializer
  require 'my_muzik_label_api/server'
  MyMuzikLabelAPI::Server.mapper = MuzikMapper
  
  # Then in your app somewhere that has access to all your server stuff
  module MuzikMapper
    def self.post_song(name, words)
      unless User.if_has_too_many_songs?
        Song.create!(:words => words)
      end
    end
  end
  
  # Integrtion test, down from musician third party app (some app using our client library) all the way up to our server API!

  Capybara.app = Rack::Builder.app do
    map "http://mymuziklabel.localdev.engineyard.com/" do
      run MyMuzikLabel::Application
    end
    map "http://musiciansthirdpartyapp.localdev.engineyard.com/" do
      run MusiciansThirdPartyApp::Server
    end
    map "http://whatever.else.com/" do
      run Rack::Client::Handler::NetHTTP
    end
  end

  MyMuzikLabelAPI::Client.mock!(Capybara.app)

  module MusiciansThirdPartyApp
    class Server < Sinatra::Base
      # do whatever yo.
    end
  end


    visit MusiciansThirdPartyApp.domain
    fill_in "write a song", :with => "And all that jazz"
    click "Upload song to MyMuzikLabel"
    #response should say "song submition recorded"
    #MyMuzikLabel should have a song with those words!

</pre>


















## Resources

[1] RealWeb
Rack-Client
twitter.com/shaiguitar