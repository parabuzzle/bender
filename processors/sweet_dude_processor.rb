module Bender::Processor
  class SweetDudeProcessor < Bender::BaseProcessor
    def process
      hear(/sweet/i) { reply 'Dude!' }
      hear(/dude/i)  { reply 'Sweet!' }
    end
  end
end
