require 'version'

describe Bender::VERSION do
  it 'returns the bender version' do
    expect( Bender::VERSION ).to eq('0.1.0')
  end
end
