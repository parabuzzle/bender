require 'webrick'
require 'mono_logger'

module Bender

  # Handles WEBrick and auto-mounting servlets
  #
  # Author::    Michael Heijmans  (mailto:parabuzzle@gmail.com)
  # Copyright:: Copyright (c) 2013-2015 Michael Heijmans
  # License::   MIT
  module HttpListener

    def self.start(bot)
      @bot = bot

      if Bender.config.http_log_file == "!BENDER_LOGGER"
        logger = Bender.log
      else
        logger = MonoLogger.new(Bender.config.http_log_file, Bender.config.http_log_rotation)
        logger.level = Bender.config.http_log_level
      end

      begin
        Bender.log.info("starting http listener on port #{Bender.config.http_port}...")
        server = WEBrick::HTTPServer.new(
                                          :Port               => Bender.config.http_port,
                                          :MaxClients         => Bender.config.http_max_clients,
                                          :Logger             => logger,
                                          :BindAddress        => Bender.config.http_listen_address,
                                          :bot                => bot,
                                        )
        Bender.log.info "Starting servlets"
        Bender::HTTP.constants.each do |i|
          klass = "Bender::HTTP::#{i.to_s}".classify
          mountpoint = klass.mountpoint
          server.mount mountpoint, klass
          Bender.log.info "  Starting servlet: #{i.to_s} mounted at #{mountpoint}"
        end
        server.start

      rescue => e
        Bender.log.error "HTTP server caught execption"
        Bender.log.error e
        raise e
      end
    end
  end
end
