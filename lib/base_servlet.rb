#Base servlet class for bender servlets
require 'webrick'

module Bender
  class BaseServlet < ::WEBrick::HTTPServlet::AbstractServlet

    def initialize(server, *options)
      @server = @config = server
      @logger = @server[:Logger]
      @options = options
      @bot = @config[:bot]
      @http_shared_secret = Bender.config.http_shared_secret
    end

    def params(request)
      request.query
    end

  end
end

