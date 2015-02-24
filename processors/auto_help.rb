module Bender::Processor

  # Description::
  #   dynamically generates and prints help
  #
  # Dependencies::
  #   none
  #
  # Configuration::
  #   none
  #
  # Authors::
  #   Michael Heijmans  (mailto:parabuzzle@gmail.com)
  class AutoHelp < Bender::BaseProcessor
    def process
      respond(/help$/i) do
        help_messages.each { |msg| reply msg }
      end
    end

    def help_messages
      Bender::Processor.constants.each_with_object([]) do |const, ary|
        klass = "Bender::Processor::#{const.to_s}".classify
        ary << klass.help if klass.respond_to?(:help)
      end.flatten
    end
  end
end
