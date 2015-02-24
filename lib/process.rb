require 'bender'

module Bender

  # Helper methods for working with the Bender process
  #
  # Author::    Michael Heijmans  (mailto:parabuzzle@gmail.com)
  # Copyright:: Copyright (c) 2013-2015 Michael Heijmans
  # License::   MIT
  module Process

    # Returns true if the given `pid` appears to be running
    # @note unlike Process#getpgid, this will return false if the pid is not in the procsess table
    def self.pid_running?(pid)
      pid = pid.to_i
      begin
        ::Process.getpgid( pid )
        return true
      rescue Errno::ESRCH
        return false
      end
    end

    # Returns the Bender pid
    def self.bender_pid
      return $$
    end

    # Writes the pid file for Bender or raises an exception if Bender is already running
    # @note handles a stale pid file and cleans it up
    def self.write_pid(pid_file=nil)
      #write a pid file
      file = pid_file || Bender.config.pid_file
      #check for ophaned pid file and handle it
      if File.exist?(file)
        fh = File.new(file, "r")
        pid = fh.readlines[0]
        if pid_running?(pid)
          Bender.log.fatal("Bender is already running as pid:#{pid}")
          raise "Bender is already running as pid:#{pid}"
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

    # removes the pid file
    def self.remove_pid(pid_file=nil)
      file = pid_file || Bender.config.pid_file
      return false unless File.exist?(file)
      File.delete(file)
      Bender.log.debug "removing pid file #{file}"
      return true
    end

    # sets the running process name in the process table
    # @note bender will appear as 'bender' when you run `ps`
    def self.set_process_name
      $0 = "bender"
    end
  end
end
