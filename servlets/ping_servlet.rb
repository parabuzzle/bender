module Bender::HTTP
  class PingServlet < Bender::BaseServlet
    @mountpoint = "/ping"

    def do_GET(request, response)
      status = 200
      content_type = "text/html"
      body = "OK\n"

      response.status = status
      response['Content-Type'] = content_type
      response.body = body
      response.body = body
    end

  end
end
