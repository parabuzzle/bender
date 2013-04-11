# For stand alone running of test
if $LIB_BASE_DIR
  @libdir = $LIB_BASE_DIR
else
  @libdir = "#{Dir.pwd}/.."
end
require 'test/unit'
require "#{@libdir}/lib/string-mixins.rb"

class AbcDef
  # test object for classify method
end

class TestStringMixins < Test::Unit::TestCase
  
  def setup
    @str = "abc_def"
  end
  
  def teardown
  end
  
  def test_capitalize
    assert_not_equal @str, "Abc_def"                                          # check that string is not capitalized
    assert_equal @str.capitalize_first_letter, "Abc_def"                      # check that string is now capitalized
    assert_not_equal @str.capitalize_first_letter.object_id, @str.object_id   # check that string didn't capitalize in place
  end
  
  def test_camelize
    assert_not_equal @str, "AbcDef"                   # check that string is not camel cased
    assert_equal @str.camelize, "AbcDef"              # check that camelize properly camel cased the string
    assert_equal "abc_def_ghi".camelize, "AbcDefGhi"  # check that multi set camel casing works
  end
  
  def test_classify
    assert_not_equal @str.class, AbcDef.class                 # Test that string is not of AbcDef class
    assert_equal @str.camelize.classify.class, AbcDef.class   # Test that Classify properly returns a AbcDef object
  end
  
end