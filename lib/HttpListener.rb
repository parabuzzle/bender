require 'webrick'

module HttpListener

  def HttpListener.start_http_listener(bot)
    @bot = bot
    p = CONFIG['http_listener']
    if p['log'] == "STDOUT"
      log = STDOUT
    elsif p['log'] == "!BENDER_LOGGER"
      log = Log
    else
      log = p['log']
    end
    begin
      Log.info("starting http listener on port #{p['port']}...")
      server = WEBrick::HTTPServer.new(:Port => p['port'], 
                                      :MaxClients => p['max_clients'], 
                                      :Logger => WEBrick::Log.new(log), 
                                      :BindAddress => p['address'],
                                      :bot=>bot)
      Log.info "Starting servlets"
      # load servlets
      Dir["#{BENDER_ROOT}/servlets/*_servlet.rb"].each do |file|
        file = file.split("/").last.gsub('.rb','')
        klass = file.camelize.classify
        server.mount klass.class_eval{@mountpoint}, klass
        Log.info "Starting servlet #{file.camelize} mounted at #{klass.class_eval{@mountpoint}}"
      end 
        
      trap "INT" do server.shutdown end
      server.start
    ensure
      Log.info("http listener shutting down")
    end
  end
end

