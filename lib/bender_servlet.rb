#Base servlet class for ymbot servlets

class BenderServlet < WEBrick::HTTPServlet::AbstractServlet
  
  def initialize(server, *options)
    @server = @config = server
    @logger = @server[:Logger]
    @options = options
    @bot = @config[:bot]
  end
  
end