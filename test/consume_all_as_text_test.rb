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

  def test_import_elements_from_text
    sel = BaseFormat.import_xml "<abc myattr='real'><otherel>foo</otherel>text</abc>"
    assert_equal 'real', sel.myattr
    assert_equal "<otherel>foo</otherel>text", sel.value
  end

  def test_import_elements_from_dom
    xml_text = "<abc myattr='real'><otherel>foo</otherel>text</abc>"
    sel = BaseFormat.import_xml Nokogiri::XML::Document.parse(xml_text)
    assert_equal 'real', sel.myattr
    assert_equal "<otherel>foo</otherel>text", sel.value
  end
end
