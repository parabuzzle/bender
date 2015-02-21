module Bender
  module IrcListener

    def self.start(bot)
      @bot = bot
      begin
        Bender.log.info("Starting irc processors.")
        Bender::Processor.constants.each do |i|
          @bot.add_processor( eval "Bender::Processor::#{i.to_s}.new" )
          Bender.log.info "  Starting processor: #{i.to_s}"
        end
        @bot.start
      rescue => e
        Bender.log.error "IRC processor caught execption"
        Bender.log.error e
        raise e
      ensure
        Bender.log.info("IRC processors shutting down...")
      end
    end

  end
end
