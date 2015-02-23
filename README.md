[![Stories in Ready](https://badge.waffle.io/parabuzzle/bender.png?label=ready&title=Ready)](https://waffle.io/parabuzzle/bender)


#Install

**Grab Application**
```
$ git clone git://github.com/parabuzzle/bender.git
```

**Install Gems**
```
$ bundle install
```

**Run It**
```
$ cd bender
$ ruby bin/server.rb
```

*note: you can also use foreman to run it: `foreman start`*


##Configuration
Look at `config/application.rb` for a list of configuration options and overrides

*note: Bender is 100% Heroku compatible and configurable via the ENV - https://github.com/parabuzzle/bender/wiki/Using-Bender-on-Heroku*


#Extending Bender
*Let's face it... this is what you are interested in ;)*

###Directory Structure
```
./config/       # config and initialization
./lib/          # directory with all support libraries (classes/modules)
./processors/   # directory for irc command processors
./servlets/     # directory for servlets
```

###Autoloader
When Bender starts, it auto loads everything so that you just put your extensions in the proper folders with the proper namespacing and restart the application for it to start working. NO EXTRA CONFIG!

**Load Order**

  1. Require ./config/application.rb
  1. Require all files in ./config/*.rb
  1. Require all files in ./lib/*.rb
  1. Require all files in ./servlets/*.rb
  1. Require all files in ./processors/*.rb
  1. Start processors - ./processors/*_processor.rb
  1. Start servlets - ./servlets/*_servlet.rb

**Autoload of Processors**

This is done via the `Bender::Processor` namespace. As long as your processor's class is namespaced there, it will be loaded.

example:

```ruby
Bender::Processor::BasicProcessor #=> loaded
Bender::Processor::AwesomeSauce   #=> loaded
Bender::WizBangProcessor          #=> not loaded
```

**Autoload of Servlets**

This is done via the `Bender::HTTP` namespace. As long as your servlet's class is namespaced there, it will be loaded.

example:

```ruby
Bender::HTTP::PingServlet  #=> loaded
Bender::HTTP::Github       #=> loaded
Bender::MyServlet          #=> not loaded
```

**More info about creating processors and servlets in the next section**


### Building an irc command processor
Just subclass `Bender::BaseProcessor` and implement the `#process` method

**This is what a processor looks like:**

```ruby
module Bender::Processor
  class BasicProcessor < Bender::BaseProcessor

    # REQUIRED! You must implement the #process method when subclassing the BaseProcessor class
    def process

      #monitor for the word 'sweet' and respond with 'dude'
      hear(/sweet/i) { reply 'Dude!' }

      # monitor for my nickname with or without a question mark and respond
      #   ie: `bender?` responds with 'Kiss my shiny metal ass'
      hear(/^#{@bot.nickname}\??$/) { reply 'Kiss my shiny metal ass' }

      # respond wraps the previous bot.nickname catching and matches on everything after the nickname
      #   ie: `bender PING` will respond with 'PONG'
      respond(/PING$/) { reply "PONG" }
    end

    # The #help class method is optional but it makes running `bender help` a lot more useful ;)
    # This method should return an array of lines to be printed in the irc
    def self.help
      [
        "sweet - replies with 'dude'",
        "#{Bender.nickname} PING - replies with 'PONG'",
        "#{Bender.nickname}? - replies with 'Kiss my shiny metal ass"
      ]
    end
  end
end
```
You simply put this code in the `./processors/` directory and restart Bender for this to start working.


### Building a servlet
Since Bender uses webrick, creating a servlet for Bender is almost the same as creating an Abstract Servlet in Webrick. **ALMOST**... The only difference is that Bender will provide the Spunk Bot object so that you can access the Spunk IRC bot from within the request to post messages to IRC or display IRC data to a webpage. This is done by inheriting from the `Bender::BaseServlet` class which has the bot.

**This is what servlet looks like**

```ruby
class GitServlet < Bender::BaseServlet
  # Provides a simple bridge of github url post hook data to IRC
  # http://localhost:9091/gitirc?room=github

  # REQUIRED! so Bender knows where to mount this
  def self.mountpoint
    "/gitirc"
  end

  def do_GET(request, response)
    status = 200
    content_type = "text/html"
    body = "bender version #{BENDER_VERSION}"
    body += "\n"

    response.status = status
    response['Content-Type'] = content_type
    response.body = body
    response.body = body
  end

  def do_POST(request, response)
    status, content_type, body = post_to_irc(request)

    response.status = status
    response['Content-Type'] = content_type
    response.body = body
  end

  private

  def post_to_irc(request)
    bot_hash = {:rooms=>[], :payload=>nil}
    request.query.collect do |key,value|
      if key.match(/^room/)
        bot_hash[:rooms] << '#' + value
      end
      if key.match(/^payload/)
        bot_hash[:payload] = value
      end
    end
    rooms = bot_hash[:rooms]
    rooms.uniq!

    if bot_hash[:payload]
      j = JSON.parse(bot_hash[:payload])
      repo = j['repository']['name']
      compare = j['compare']
      pusher = j['pusher']['name']
      owner = j['repository']['owner']['name']
      branch = j['ref']
      unless pusher == "name"
        rooms.each do |r|
          unless $bot.joined_rooms.include? r
            @bot.join_room r
          end
          @bot.say r, "[git-push] #{pusher} pushed to #{owner}/#{repo} [ref: #{branch}]"
          @bot.say r, "[git-push] #{compare}"
        end
      end
    end

    return 200, "text/plain", "accepted"
  end
end
```

This servlet will listen for a post from your github post hook on your repo and bridge the data into the room provided. *ie - http://myserver.com:9019/gitirc?room=github will post to the #github room whenever you push to your repo*

This code should be put into the `./servlets/` directory to get included at startup.


#Contributing

  1. fork the repository
  1. create a feature branch
  1. add your awesome code
  1. send a pull request
  1. have a beer


#License

The MIT License (MIT)

Copyright (c) 2013-2015 Michael Heijmans

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
