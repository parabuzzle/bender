require 'webrick'

module HttpListener

  def HttpListener.start_http_listener(bot)
    @bot           = bot
    log_file       = ENV['HTTP_LOG_FILE']       || STDOUT
    port           = ENV['PORT']                || 9091
    max_clients    = ENV['HTTP_MAX_CLIENTS']    || 4
    listen_address = ENV['HTTP_LISTEN_ADDRESS'] || '0.0.0.0'

    if log_file == "!BENDER_LOGGER"
      log_file = Log
    end

    begin
      Log.info("starting http listener on port #{port}...")
      server = WEBrick::HTTPServer.new(:Port => port,
                                      :MaxClients => max_clients,
                                      :Logger => WEBrick::Log.new(log_file),
                                      :BindAddress => listen_address,
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

