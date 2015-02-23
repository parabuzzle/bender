module Bender::Processor

  # Description::
  #   Dude Where's My Car? c'mon!
  #
  # Dependencies::
  #   none
  #
  # Configuration::
  #   none
  #
  # Authors::
  #   Michael Heijmans  (mailto:parabuzzle@gmail.com)
  class SweetDudeProcessor < Bender::BaseProcessor
    def process
      hear(/sweet/i) { reply 'Dude!' }
      hear(/dude/i)  { reply 'Sweet!' }
    end

    def self.help
      [
        "sweet - replies with 'Dude!",
        "dude - replies with 'Sweet!'"
      ]
    end
  end
end
