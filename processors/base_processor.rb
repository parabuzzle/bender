module BenderProcessor
  class BaseProcessor
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
      # rubular.com is a really good for coming up with regex ;)
      case msg
         when /^#{bot.nickname},?$/i
           # match nickname
           bot.say room, "Kiss my shiny metal ass"
          
          when /^#{bot.nickname},? version$/i
            # match nickname, version
            bot.say room, BENDER_VERSION
        
      end # end case messages
    end # end BaseProcessor#call
  end # end BaseProcessor
end # end BenderProcessor
