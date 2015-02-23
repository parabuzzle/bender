# Note: Bender::Config is a singlton class. Testing a singlton is.. umm.. interesting.
require 'config'

describe Bender::Config do

  before(:each) do
    @config = Bender::Config.instance
  end

  describe '#configure' do

    context 'defaults' do

      it 'accepts a block' do
        config = Bender::Config.instance
        expect( config.test1 ).to eq(nil)
        Bender::Config.configure do |c|
          c.test1 = "foo"
        end
        expect( config.test1 ).to eq("foo")
      end

      it 'sets some defaults' do
        expect( Bender::Config.instance.nickname ).to eq('bender')
      end

      it 'returns the instance when not passed a block' do
        expect( Bender::Config.configure ).to eq(Bender::Config.instance)
      end

      it 'sets the log level to the proper level using the Logger constant' do
        expect( @config.irc_log_level ).to eq(MonoLogger::INFO)
      end

      it 'sets up the logger' do
        expect( @config.log.class ).to eq(MonoLogger)
      end

    end

    context 'with block' do
      it 'overrides defaults' do
        expect( Bender::Config.instance.nickname ).to eq('bender')
        Bender::Config.configure do |c|
          c.nickname = "bender_bot"
        end
        expect( Bender::Config.instance.nickname ).to eq('bender_bot')
      end
    end

    context 'with environment' do
      it 'set config params through the environment' do
        expect( Bender::Config.instance.fullname ).to eq('bender_env')
      end
    end

  end

end
