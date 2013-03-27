## Synopsis

The three main concepts to grasp here are:

- SERVER: The API provider.
- CLIENT: A library used to request the API.
- APP: A entirely different application that uses the client to consume the API.

In the mapper examples there's an `api` concept, which separates out the api endpoints codewise, from the server itself which provides it. Both the server.rb and the server class in api.rb should compare to SERVER in other examples. 

By the end of seeing the talk the mapper examples should hopefully make at the least more sense than beforehand!

## Check out

The various approaches 

  isolation
  sandbox
  fakes
  mapper

Each one of them has a test file which you can run as a simple unit test file. I used Sinatra for both the server and the fakes, but the ideas here hold when using a rails server. 

I also added a mapper-faraday directory which shows the mapper pattern using the faraday client in place of rack-client. The idea of using faraday should hold for all approaches: faraday and rack-client are rest clients that have similar concepts and of being able to direct traffic from them to rack_builder etc.