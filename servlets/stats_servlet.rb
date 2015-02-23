# Description:
#   Provides information about the bot
#
# Dependencies:
#   none
#
# Configuration:
#   Bender.config.http_auth_token
#
# Authors:
#   Michael Heijmans  (mailto:parabuzzle@gmail.com)

module Bender::HTTP
  class StatsServlet < Bender::BaseServlet

    def do_GET(request, response)
      status = 200
      content_type = "text/html"
      body = []
      body << "<table><tr><th>Current Active Rooms</th></tr>"
      @bot.joined_rooms.each do |r|
        body << "<tr><td>#{r}</td></tr>"
      end
      body << "<table><br/><br/><br/>"
      body << "bender version #{Bender::VERSION}"

      body = body.join("\n")

      body += "\n"

      if @auth_token
        unless params(request)['token'] == @auth_token
          status = 403
          body = "You are not authorized to view this resource\n"
        end
      end

      response.status = status
      response['Content-Type'] = content_type
      response.body = body
      response.body = body
    end

    def self.mountpoint
      "/stats"
    end
  end
end
