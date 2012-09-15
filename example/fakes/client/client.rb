require 'json'

module MyMuzikLabelAPI
  class Client

    class ServerDown < StandardError; end

    attr_accessor :domain

    def mock!
      # the idea holds, implementation be damned
      require 'realweb'
      @server = RealWeb.start_server("fake_server_config.ru")
      self.domain = "http://#{@server.host}:#{@server.port}"
    end

    def client
      @client ||= Rack::Client.new(@domain)
    end

    def post_song(name, words)
      JSON.parse(client.post("/song/#{name}", {}, {:words => words}).body)['status']
    end

    def get_song(name)
      JSON.parse(client.get("/song/#{name}").body)['words']
    end
  end
end