require File.dirname(__FILE__) + '/test_helper.rb'
require 'nokogiri'

class TestPartialImport < Test::Unit::TestCase
  class PartialBaseFormat < XMLElement
    xmlformat 'Base Format'
  end

  class PartialSimpleElement < PartialBaseFormat
    elwithvalue
    elname 'abc'
    xmlattr :myattr
  end

  def test_partial_elements_in_text
    sel = PartialBaseFormat.import_xml "<abc><otherel></otherel>text</abc>"
    assert_equal "text", sel.value
  end

  def test_partial_elements_in_dom
    xml_text = "<abc><otherel></otherel>text</abc>"
    sel = PartialBaseFormat.import_xml Nokogiri::XML::Document.parse(xml_text)
    assert_equal "text", sel.value
  end

  def test_partial_attributes_in_text
    sel = PartialBaseFormat.import_xml "<abc myattr='real' someattr='xpto'>text</abc>"
    assert_equal "text", sel.value
    assert_equal "real", sel.myattr
  end

  def test_partial_attributes_in_dom
    xml_text = "<abc myattr='real' someattr='xpto'>text</abc>"
    sel = PartialBaseFormat.import_xml Nokogiri::XML::Document.parse(xml_text)
    assert_equal "text", sel.value
    assert_equal "real", sel.myattr
  end
end
