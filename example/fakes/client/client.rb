require 'json'

module MyMuzikLabelAPI
  class Client

    class ServerDown < StandardError; end

    attr_accessor :domain

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