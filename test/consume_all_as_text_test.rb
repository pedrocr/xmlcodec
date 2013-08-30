require File.dirname(__FILE__) + '/test_helper.rb'
require 'nokogiri'

class ConsumeAllAsTextTest < Test::Unit::TestCase
  class BaseFormat < XMLElement
    xmlformat 'Base Format'
  end

  class SimpleElement < BaseFormat
    elallvalue
    elname 'abc'
    xmlattr :myattr
  end

  # Tests both through DOM and text to make sure both code paths are working
  def double_test(text)
    sel = BaseFormat.import_xml text
    yield sel
    sel = BaseFormat.import_xml Nokogiri::XML::Document.parse(text)
    yield sel
  end

  def test_import_elements
    double_test("<abc myattr='real'><otherel>foo</otherel>text</abc>") do |sel|
      assert_equal 'real', sel.myattr
      assert_equal "<otherel>foo</otherel>text", sel.value
    end
  end
end
