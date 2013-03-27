# SANDBOX
#
# there's no backend fake to support it. so I'll just need to mock it out
# @client.mock(:post_song).and_return("ok") / Fakeweb etc.
#
# We could use a fog-like backend mocking system but we don't know that your fake corresponds to the real server info.
#
# We could also expose a sandbox in general for cool muscian apps to access it and use the sandbox for their integration tests.
# Providers like Salesforce, Terremark etc expose sandboxes, then you could just set your client appropriately and use that:
#
# @client.domain = "https://sandbox.my-muzik-label.com"
# @client.post_song('rock', 'all that jazz')

require '../client/client'

class SocialMusicUploader
  @@uploaded_songs = []

  def self.muzik_label_client
    @client = MyMuzikLabelAPI::Client.new
    @client.domain = 'mymuziklabel.localdev.com'
    @client
  end
  
  def self.upload_song_to_muzik_label(title, words)
    muzik_label_client.post_song(title, words)
  end

end
