module Bender::Processor
  class BasicProcessor < Bender::BaseProcessor
    def process
      respond(/version\??$/i) { reply "#{Bender::VERSION}" }
      respond(/PING$/) { reply "PONG" }
      hear(/^#{@bot.nickname}\??$/) { reply 'Kiss my shiny metal ass' }
    end
  end
end
