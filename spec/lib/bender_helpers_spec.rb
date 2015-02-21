require 'bender_helpers'
include Bender::Helpers


describe Bender::Helpers do

  before(:each) do
    @pid_file = ENV['PID_FILE'] = './bender.pid.test'
    if File.exist?(@pid_file)
      File.delete(@pid_file)
    end
    @mypid = bender_pid
  end

  after(:each) do
    if File.exist?(@pid_file)
      File.delete(@pid_file)
    end
  end

  describe '#write_pid' do
    it 'writes a pid file' do
      expect( File.exist?(@pid_file) ).to eq(false)
      write_pid
      expect( File.exist?(@pid_file) ).to eq(true)
    end
  end

  describe '#bender_pid' do
    it 'returns the pid of the current running process' do
      expect( bender_pid ).to eq($$)
    end
  end

  describe '#pid_running?(pid)' do
    it 'returns true for a running pid' do
      expect( pid_running?(1) ).to eq(true)
    end

    it 'returns false for a dead pid' do
      expect( pid_running?(1234567) ).to eq(false)
    end
  end

  describe '#remove_pid' do
    it 'removes the pid file' do
      write_pid
      expect( File.exist?(@pid_file) ).to eq(true)
      remove_pid
      expect( File.exist?(@pid_file) ).to eq(false)
    end
  end

  describe '#spunk_options_from_config' do
    it 'returns a config hash for spunk based on the Bender::Config object' do
      c = spunk_options_from_config
      expect( c[:nickname] ).to eq('bender')
    end
  end
end
