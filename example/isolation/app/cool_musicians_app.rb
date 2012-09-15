# ISOLATION
#
# there's no backend fake to support it. so I'll just need to mock it out
# @client.mock(:post_song).and_return("ok") / Fakeweb etc.
#
# We could use a fog-like backend mocking system but we don't know that your fake corresponds to the real server info.
