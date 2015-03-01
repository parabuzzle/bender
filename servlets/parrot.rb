module Bender::HTTP

  # Description:
  #   a simple ping endpoint
  #
  # Dependencies::
  #   none
  #
  # Configuration::
  #   none
  #
  # Authors::
  #   Michael Heijmans  (mailto:parabuzzle@gmail.com)
  class Parrot < Bender::BaseServlet

    def do_GET(request, response)
      status = 200
      content_type = "text/html"
      body = []

      body << "Params:"
      params(request).each do |k, v|
        body << "#{k} = #{v}"
      end
      body = body.join("<br/>")
      body += "\n"

      response.status = status
      response['Content-Type'] = content_type
      response.body = body
      response.body = body

    end

    def self.mountpoint
      "/parrot"
    end
  end
end
