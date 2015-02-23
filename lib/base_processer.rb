require 'thread'

module Bender
  class BaseProcessor
    attr_reader :command, :msg, :bot, :room, :origin

    def initialize
      @mutex   = Mutex.new
    end

    def call(opts)
      @mutex.synchronize {
        @command  = opts[:command]
        @origin   = opts[:origin]
        @msg      = opts[:msg]
        @bot      = opts[:bot]
        @room     = opts[:room]
      }
      process
    end

    def process
      raise NotImplementedError, 'you must implement #process method'
    end

    def hear(regexp, &block)
      return unless should_process?
      return unless @msg
      match = @msg.match(regexp)
      yield(match) if match
    end

    def respond(regexp, &block)
      return unless directly_addressed?
      return unless should_process?
      msg = @msg[@bot.nickname.length,@msg.length]
      match = msg.match(regexp)
      yield(msg, match) if match
    end

    def reply(message)
      bot.say @room, message
    end

    def directly_addressed?
      return false unless @msg
      return true if @msg.match(/^#{bot.nickname}/i)
      return false
    end

    def should_process?
      return false if @bot.nil?
      return false if @origin.nil?
      return false if @origin.nickname == @bot.nickname
      true
    end

  end
end
