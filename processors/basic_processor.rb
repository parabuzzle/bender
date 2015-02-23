module Bender::Processor

  # Description::
  #   All the basic stuff Bender should do
  #
  # Dependencies::
  #   none
  #
  # Configuration::
  #   none
  #
  # Authors::
  #   Michael Heijmans  (mailto:parabuzzle@gmail.com)
  class BasicProcessor < Bender::BaseProcessor
    def process
      respond(/version\??$/i)       { reply "#{Bender::VERSION}" }
      respond(/PING$/)              { reply "PONG" }
      hear(/^#{@bot.nickname}\??$/) { reply 'Kiss my shiny metal ass' }
    end

    def self.help
      [
        "#{Bender.nickname} version - replies with the Bender Version",
        "#{Bender.nickname} PING - replies with 'PONG'",
        "#{Bender.nickname}? - replies with 'Kiss my shiny metal ass"
      ]
    end
  end
end
