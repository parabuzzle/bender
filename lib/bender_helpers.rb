module BenderHelpers
  
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

  def write_pid
    #write a pid file
    file = CONFIG['pid_file']
    #check for ophaned pid file and handle it
    if File.exist?(file)
      fh = File.new(file, "r")
      pid = fh.readlines[0]
      if pid_running?(pid)
        Log.error("Bender is already running as pid:#{pid}")
        puts "Bender is already running as pid:#{pid}"
        exit 1
      else
        Log.warn("found orphaned pid file... removing")
        puts "found orphaned pid file... removing"
        fh.close
        File.delete(file)
      end
    end
    fh = File.new(file, "w")
    mypid = $$
    Log.debug "Writing pid file #{file} pid:#{mypid}"
    fh.print(mypid)
    fh.flush
    fh.close
    return true
  end
  
  def remove_pid
    file = CONFIG['pid_file']
    File.delete(file)
    Log.debug "removing pid file #{file}"
    return true
  end
  
end