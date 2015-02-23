require 'webrick'

module Bender

  # Base class for all Servlets
  #   -- Provides uri autoload and helpers for working with SpunkBot
  #
  # Author::    Michael Heijmans  (mailto:parabuzzle@gmail.com)
  # Copyright:: Copyright (c) 2013-2015 Michael Heijmans
  # License::   MIT
  class BaseServlet < ::WEBrick::HTTPServlet::AbstractServlet

    def initialize(server, *options)
      @server     = @config = server
      @logger     = @server[:Logger]
      @options    = options
      @bot        = @config[:bot]
      @auth_token = Bender.config.http_auth_token
    end

    def params(request)
      request.query
    end

    def self.mountpoint
      obj = self
      raise NotImplementedError, "you must implement #mountpoint class method for #{obj}"
    end

  end
end

