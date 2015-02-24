require 'thread'

module Bender

  # The base class for all Processors
  #   -- Provides helpers for working with SpunkBot
  #
  # @abstract Subclass and override {#process} to implement
  #
  # Author::    Michael Heijmans  (mailto:parabuzzle@gmail.com)
  # Copyright:: Copyright (c) 2013-2015 Michael Heijmans
  # License::   MIT
  class BaseProcessor

    # @!attribute [r] command
    #   The IRC command issued
    # @!attribute [r] msg
    #   The IRC message if any
    # @!attribute [r] bot
    #   The SpunkBot object
    # @!attribute [r] room
    #   The room that the command was issued from if any
    # @!attribute [r] origin
    #   The origin object of what issued the command if any
    attr_reader :command, :msg, :bot, :room, :origin

    def initialize
      @mutex   = Mutex.new
    end

    # The raw call that SpunkBot uses when a line of text is captured by the bot.
    # @note This method should not be used within the context of a Bender::Processor, use #process instead
    # @see #process
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

    # Called on each line that SpunkBot sees
    # @note Use this method in your processors to make Bender do things
    def process
      obj = self
      raise NotImplementedError, "you must implement #process method for #{obj.class}"
    end

    # A helper for listening for a match to `regexp` and processing it in the block
    #
    # @example Hear "sweet" and reply with "dude"
    #   hear( 'sweet' ) { reply "dude" }
    def hear(regexp, &block)
      return unless should_process?
      return unless @msg
      match = @msg.match(regexp)
      yield(match) if match
    end

    # A helper for responding when the bot's nickname is directly addressed and processing in a block
    #
    # @example "bender hello" replies with "hi!"
    #   respond( 'hello' ) { reply "hi!" } #=> "bender hello" :: replies with "hi!"
    #   respond( 'hello' ) { reply "hi!" } #=> "hello" :: nothing is sent
    def respond(regexp, &block)
      return unless directly_addressed?
      return unless should_process?
      msg = @msg[@bot.nickname.length,@msg.length]
      match = msg.match(regexp)
      yield(msg, match) if match
    end

    # A helper for responding to a given room with a `message`
    def reply(message)
      bot.say @room, message if @room
    end

    protected

      # A helper used by #respond to test if Bender is being addressed directly
      #
      # @see #respond
      def directly_addressed?
        return false unless @msg
        return true if @msg.match(/^\@?#{bot.nickname}/i)
        return false
      end

      # A helper used by #hear and #respond to test if the given string is something we care about
      #
      # @see #hear
      # @see #respond
      def should_process?
        return false if @bot.nil?
        return false if @origin.nil?
        return false if @origin.nickname == @bot.nickname
        true
      end

  end
end
