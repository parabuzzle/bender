module IrcListener
  
  def IrcListener.start_irc_listener(bot)
    @bot = bot
    begin
      Log.info("starting irc processors.")
      Dir["#{BENDER_ROOT}/processors/*_processor.rb"].each do |file| 
        file = file.split("/").last.gsub('.rb','')
        @bot.add_processor(eval "BenderProcessor::#{file.camelize}.new")
        Log.info "starting processor #{file.camelize}"
      end
      @bot.start
    ensure
      Log.info("irc processors shutting down...")
    end
  end
  
end