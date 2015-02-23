require 'webrick'

module Bender

  # Base class for all Servlets
  #   -- Provides uri autoload and helpers for working with SpunkBot
  #
  # @abstract Subclass and override {#mountpoint} to implement
  #
  # Author::    Michael Heijmans  (mailto:parabuzzle@gmail.com)
  # Copyright:: Copyright (c) 2013-2015 Michael Heijmans
  # License::   MIT
  class BaseServlet < ::WEBrick::HTTPServlet::AbstractServlet

    # @!attribute [r] server
    #   The server object
    # @!attribute [r] config
    #   The config object
    # @!attribute [r] options
    #   The passed in options hash
    # @!attribute [r] bot
    #   The SpunkBot object
    # @!attribute [r] auth_token
    #   The auth_token defined in Bender.config.http_auth_token

    def initialize(server, *options)
      @server     = @config = server
      @logger     = @server[:Logger]
      @options    = options
      @bot        = @config[:bot]
      @auth_token = Bender.config.http_auth_token
    end

    # A helper to return the query params hash for a given `request`
    def params(request)
      request.query
    end

    # The uri mountpoint to use for the Servlet
    # @example Mount my servlet at '/stats'
    #   def self.mountpoint
    #     './stats'
    #   end
    def self.mountpoint
      obj = self
      raise NotImplementedError, "you must implement #mountpoint class method for #{obj}"
    end

  end
end

