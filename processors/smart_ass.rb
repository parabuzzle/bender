module Bender::Processor

  # Description::
  #   Makes smart ass comments
  #
  # Dependencies::
  #   none
  #
  # Configuration::
  #   none
  #
  # Authors::
  #   Michael Heijmans  (mailto:parabuzzle@gmail.com)
  class SmartAss < Bender::BaseProcessor
    def process
      hear(/coffee/i)       { reply "Coffee's for CLOSERS!!!" }
      hear(/beer/i)         { reply "Beer you say? You buyin' #{@origin.nickname}?" }
      hear(/fuck/i)         { reply "Hey! watch the fucking language" }
      hear(/stupid robot/i) { reply "I don't tell you how to tell me what to do, so don't tell me how to do what you tell me to do" }
    end
  end
end
