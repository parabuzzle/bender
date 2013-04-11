#Install

**Install Gems**
```
$ gem install spunk
```

**Grab Application**
```
$ git clone git://github.com/parabuzzle/bender.git
```

**Run It**
```
$ cd bender
$ ruby bender.rb
```


##Configuration
You can configure bender using config.yml found in the top level directory. If you set the log file to STDOUT it will write the logs to the console. Otherwise, they will be written to the file defined by the setting.

Also, if you set the http listener's log file to !BENDER_LOGGER the webrick log will use the same logger instance defined in the log section of the config script. These are separated out so that you can have your servlet access log separate from your application log. 


#Extending Bender
*Let's face it... this is what you are interested in ;)*

###Directory Structure
```
./bender.rb     #main routine - attaches to shell and runs the bot
./start.sh      #runs main bender.rb and detaches
./stop.sh       #uses the pid file to kill off the bender
./config.yml    #configuration file
./lib/          #directory with all needed libraries (classes/modules)
./processors/   #directory for irc command processors
./servlets/     #directory for servlets
```

###Autoloader
When Bender starts, it auto loads everything so that you just put your extensions in the proper folders with the proper naming convention and restart the application for it to start working. NO EXTRA CONFIG!

**Load Order**
 1. Require all files in ./lib/*.rb
 1. Require all files in ./servlets/*.rb
 1. Require all files in ./processors/*.rb
 1. Start processors - ./processors/*_processor.rb
 1. Start servlets - ./servlets/*_servlet.rb

**Autoload of Processors**

This is done by loading all ./processors/*_processor.rb files and camel casing the file name to load the class. *ie - base_processor.rb is loaded as BaseProcessor.new*

**Autoload of Servlets**

This is done by loading all ./servlets/*_servlet.rb files and camel casing the file name to the class. *ie - stats_servlet.rb is loaded as StatsServlet.new*

Servlets also must have the mountpoint variable defined so that Bender knows what uri to mount your servlet class on... 
```
@mountpoint = "/stats" # will load StatsServlet on /stats on your web server
```

**More info about creating processors and servlets in the next section**


### Building an irc command processor
This is a simple IOC (inversion of control) style system where you define a class that implements the "call" method that takes a hash as its argument.

**This is what a processor looks like:**
```
module BenderProcessor
  class MyProcessor
    def call(hash)
      # helper variables
      command = hash[:command]
      origin = hash[:origin]
      msg = hash[:msg]
      bot = hash[:bot]
      room = hash[:room]
      
      if origin.nil?
        # if origin is nil.. just exit the processor now...
        return
      end
      
      if origin.nickname == bot.nickname
        # if the bot is origin.. just exit the processor now...
        return
      end
      
      # Parse Messages
      # http://rubular.com is really good for coming up with regex ;)
      case msg
         when /^#{bot.nickname},?$/i
           # match 'nickname'
           # says "Kiss my shiny metal ass"
           bot.say room, "Kiss my shiny metal ass"
          
          when /^#{bot.nickname},? version$/i
            # match 'nickname, version'
            # says version
            bot.say room, BENDER_VERSION

          when /^#{bot.nickname}.? say hello/i
            # match 'nickname, say hello'
            # says "Hello World"
            bot.say room, "Hello World"

          when /^#{bot.nickname},? say goodbye/i
            # match 'nickname, say goodbye'
            # says "Goodbye Cruel World" and kicks its self out of the room
            bot.say room, "Goodbye Cruel World"
            bot.say room, "/kick #{bot.nickname}"
        
      end # end case messages
    end # end MyProcessor#call
  end # end MyProcessor
end # end BenderProcessor
```
You simply put this code in ./processors/my_processor.rb and researt Bender for this to start working.

*note - my_processor.rb matches the class name of MyProcessor*

*also note - MyProcessor is in the BenderProcessor module... This is because Bender only loads processors within the BenderProcessor namespace - BenderProcessor::MyProcessor.new*


### Building a servlet
Since Bender uses webrick, creating a servlet for Bender is almost the same as creating an Abstract Servlet in Webrick. **ALMOST**... The only difference is that Bender will provide the Spunk Bot object in the request so that you can access the Spunk IRC bot from within the request to post messages to IRC or display IRC data to a webpage. This is done by inheriting from the BenderServlet class which has the bot. 

**This is what servlet looks like**
```
class GitServlet < BenderServlet
  # Provides a simple bridge of github url post hook data to IRC
  # http://localhost:9091/gitirc?room=github
  @mountpoint = "/gitirc" # required for Bender to know where to mount the servlet

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
This servlet will listen for a post from your github post hook on your repo and bridge the data in to the room provided. *ie - http://myserver.com:9019/gitirc?room=github will post to the #github room whenever you push to your repo*

This code should be put in to ./servlets/git_servlet.rb to be loaded as GitServlet on uri /gitirc

*note the file name git_servlet.rb corresponds to the class name GitServlet*
