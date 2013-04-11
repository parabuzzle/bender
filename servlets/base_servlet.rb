class BaseServlet < BenderServlet
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
    body << "bender version #{BENDER_VERSION}"
        
    body = body.join("\n")  
    
    body += "\n"

    response.status = status
    response['Content-Type'] = content_type
    response.body = body
    response.body = body
  end
  
end