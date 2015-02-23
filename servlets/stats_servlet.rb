module Bender::HTTP
  class StatsServlet < Bender::BaseServlet
    @mountpoint = "/stats"

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

      @logger.info @http_shared_secret

      if @http_shared_secret
        unless params(request)['token'] == @http_shared_secret
          status = 403
          body = "You are not authorized to view this resource\n"
        end
      end

      response.status = status
      response['Content-Type'] = content_type
      response.body = body
      response.body = body
    end

  end
end
