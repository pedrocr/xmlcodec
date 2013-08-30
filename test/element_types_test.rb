require File.dirname(__FILE__) + '/test_helper.rb'
require 'nokogiri'

class TestElementTypes < Test::Unit::TestCase
  class ElementTypesBaseFormat < XMLElement
    xmlformat 'Base Format'
  end

  class EmptyElement < ElementTypesBaseFormat
    elname 'empty'
  end

  class ValueElement < ElementTypesBaseFormat
    elwithvalue
    elname 'value'
  end

  class AllValueElement < ElementTypesBaseFormat
    elallvalue
    elname 'allvalue'
  end

  class SubelementsElement < ElementTypesBaseFormat
    elname 'subelements'
    xmlsubelements
  end

  def test_elwithvalue
    assert_equal true, ValueElement.hasvalue?
    assert_equal true, ValueElement.new.hasvalue?
    assert_equal false, EmptyElement.hasvalue?
    assert_equal false, EmptyElement.new.hasvalue?
  end

  def test_elallvaluevalue
    assert_equal true, AllValueElement.allvalue?
    assert_equal true, AllValueElement.new.allvalue?
    assert_equal false, EmptyElement.allvalue?
    assert_equal false, EmptyElement.new.allvalue?
  end

  def test_xmlsubelements
    assert_equal true, SubelementsElement.has_subelements?
    assert_equal true, SubelementsElement.has_subelements?
    assert_equal false, EmptyElement.has_subelements?
    assert_equal false, EmptyElement.has_subelements?
  end
end
