module Bender::Processor
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
