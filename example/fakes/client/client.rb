require 'json'
module MyMuzikLabelAPI
  class Client

    class ServerDown < StandardError; end

    attr_accessor :domain

    def mock!
      # for the example in fakes/app/cool_musicans_app.rb
      # the idea holds, implementation be damned
      # use our fake app in consumer applications
      require 'realweb'
      @server = RealWeb.start_server("fake_server_config.ru")
      self.domain = "http://#{@server.host}:#{@server.port}"
    end

    def client
      @client ||= Rack::Client.new(@domain)
    end

    def post_song(name, words)
      JSON.parse(client.post("http://#{@domain}/song/#{name}", {}, {:words => words}).body)['status']
    end

    def get_song(name)
      JSON.parse(client.get("http://#{@domain}/song/#{name}").body)['words']
    end
  end
end