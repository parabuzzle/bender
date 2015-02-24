describe Bender::Process do

  before(:each) do
    @pid_file = ENV['PID_FILE'] = Bender.config.pid_file = './bender.pid.test'
    @pid_file2 = './bender.pid.test2'

    [ @pid_file, @pid_file2 ].each { |file| File.delete(file) if File.exist?(file) }

    @mypid = Bender::Process.bender_pid
  end

  after(:each) do
    File.delete(@pid_file) if File.exist?(@pid_file)
  end

  describe '#write_pid' do
    it 'writes a pid file' do
      expect( File.exist?(@pid_file) ).to eq(false)
      expect( Bender::Process.write_pid ).to eq(true)
      expect( File.exist?(@pid_file) ).to eq(true)
    end
    it 'accepts the pid file name as an arguement' do
      expect( File.exist?(@pid_file2) ).to eq(false)
      expect( Bender::Process.write_pid(@pid_file2) ).to eq(true)
      expect( File.exist?(@pid_file2) ).to eq(true)
    end
  end

  describe '#bender_pid' do
    it 'returns the pid of the current running process' do
      expect( Bender::Process.bender_pid ).to eq($$)
    end
  end

  describe '#pid_running?(pid)' do
    it 'returns true for a running pid' do
      expect( Bender::Process.pid_running?(1) ).to eq(true)
    end

    it 'returns false for a dead pid' do
      expect( Bender::Process.pid_running?(1234567) ).to eq(false)
    end
  end

  describe '#remove_pid' do
    it 'removes the pid file' do
      Bender::Process.write_pid
      expect( File.exist?(@pid_file) ).to eq(true)
      expect( Bender::Process.remove_pid ).to eq(true)
      expect( File.exist?(@pid_file) ).to eq(false)
    end

    it 'accepts the pid file name as an arguement' do
      Bender::Process.write_pid(@pid_file2)
      expect( File.exist?(@pid_file2) ).to eq(true)
      expect( Bender::Process.remove_pid(@pid_file2) ). to eq(true)
      expect( File.exist?(@pid_file2) ).to eq(false)
    end

    it "doesn't break if the file is missing" do
      expect( File.exist?('./test_file') ).to eq(false)
      expect( Bender::Process.remove_pid('./test_file') ).to eq(false)
      expect( File.exist?('./test_file') ).to eq(false)
    end
  end
end
