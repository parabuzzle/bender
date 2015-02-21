require 'string-mixins'

describe String do

  describe '#capitalize_first_letter' do
    it 'capitalizes the first letter of a string' do
      expect( 'hello'.capitalize_first_letter ).to eq( 'Hello' )
    end

    it 'only does the first letter of a string' do
      expect( 'hello world'.capitalize_first_letter ).to eq( 'Hello world' )
    end
  end

  describe '#capitalize_first_letter!' do
    it 'capitalizes the first letter of a string' do
      expect( 'hello'.capitalize_first_letter ).to eq( 'Hello' )
    end

    it 'replaces the string in place' do
      str = 'hello'
      expect( str.capitalize_first_letter! ).to eq( str )
    end
  end

  describe '#camelize' do
    it 'camel cases a string with underscores' do
      expect( 'hello_world'.camelize ).to eq( 'HelloWorld' )
    end

    it 'handles strings without underscores' do
      expect( 'helloworld'.camelize ).to eq( 'Helloworld' )
    end
  end

  describe '#classify' do
    it 'turns a string into its corresponding class constant' do
      expect( 'Fixnum'.classify ).to eq(Fixnum)
    end

    it "doesn't handle strings that aren't able to be classify-ed" do
      expect{ 'fixnum'.classify }.to raise_error( NameError )
    end
  end

  describe '#to_bool' do
    it 'turns a boolean compatiable string into a boolean' do
      expect( 'true'.to_bool ).to  eq(true)
      expect( 'false'.to_bool ).to eq(false)
    end

    it 'handles capitalizations' do
      expect( 'True'.to_bool ).to  eq(true)
      expect( 'TRUE'.to_bool ).to  eq(true)
      expect( 'tRuE'.to_bool ).to  eq(true)
      expect( 'fAlse'.to_bool ).to eq(false)
    end

    it 'handles numbers in strings' do
      expect( '1'.to_bool ).to eq(true)
      expect( '0'.to_bool ).to eq(false)
    end

    it 'handles yes and no' do
      expect( 'yes'.to_bool ).to eq(true)
      expect( 'no'.to_bool ).to  eq(false)
    end

    it 'raises and error when the string is not castable to a boolean' do
      expect{ 'foobar'.to_bool }.to raise_error(TypeError)
    end

  end

end
