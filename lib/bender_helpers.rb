require 'bender'

module Bender

  # These methods are used when starting and stop the server
  #
  # Author::    Michael Heijmans  (mailto:parabuzzle@gmail.com)
  # Copyright:: Copyright (c) 2013-2015 Michael Heijmans
  # License::   MIT
  module Helpers

    ##helper methods
    def pid_running?(pid)
      pid = pid.to_i
      begin
        Process.getpgid( pid )
        return true
      rescue Errno::ESRCH
        return false
      end
    end

    def bender_pid
      return $$
    end

    def write_pid
      #write a pid file
      file = Bender.config.pid_file
      #check for ophaned pid file and handle it
      if File.exist?(file)
        fh = File.new(file, "r")
        pid = fh.readlines[0]
        if pid_running?(pid)
          Bender.log.error("Bender is already running as pid:#{pid}")
          puts "Bender is already running as pid:#{pid}"
          exit 1
        else
          Bender.log.warn("found orphaned pid file... removing")
          puts "found orphaned pid file... removing"
          fh.close
          File.delete(file)
        end
      end
      fh = File.new(file, "w")
      mypid = $$
      Bender.log.debug "Writing pid file #{file} pid:#{mypid}"
      fh.print(mypid)
      fh.flush
      fh.close
      return true
    end

    def remove_pid
      file = Bender.config.pid_file
      File.delete(file)
      Bender.log.debug "removing pid file #{file}"
      return true
    end

    def spunk_options_from_config
      c = Bender::Config.instance

      { invite_ok:         c.irc_accept_invites,
        username:          c.username,
        fullname:          c.fullname,
        nickname:          c.nickname,
        nickserv_password: c.nickserv_password,
        hostname:          c.irc_server,
        port:              c.irc_port,
        token:             c.irc_token,
        ssl:               c.irc_use_ssl,
        logger:            c.log,
      }
    end

    def connect_to_default_rooms
      c = Bender::Config.instance
      if c.bot
        c.log.info "joining default rooms"

        c.irc_rooms.each { |room|
          room = '#' + room unless room.match(/^\#/)
          c.log.debug "  joining #{room}"
          c.bot.join_room room
        }
      else
        c.log.error "cannot connect to rooms - No bot found!"
        return false
      end
      return true
    end
  end
end
