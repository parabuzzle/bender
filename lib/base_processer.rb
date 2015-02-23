require 'thread'

module Bender

  # The base class for all Processors
  #   -- Provides helpers for working with SpunkBot
  #
  # Author::    Michael Heijmans  (mailto:parabuzzle@gmail.com)
  # Copyright:: Copyright (c) 2013-2015 Michael Heijmans
  # License::   MIT
  class BaseProcessor
    attr_reader :command, :msg, :bot, :room, :origin

    def initialize
      @mutex   = Mutex.new
    end

    # Method is called by SpunkBot on each line recieved from a joined room
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
      obj = self
      raise NotImplementedError, "you must implement #process method for #{obj.class}"
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
