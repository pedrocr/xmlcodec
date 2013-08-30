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

  # Tests both through DOM and text to make sure both code paths are working
  def double_test(text)
    sel = PartialBaseFormat.import_xml text
    yield sel
    sel = PartialBaseFormat.import_xml Nokogiri::XML::Document.parse(text)
    yield sel
  end

  def test_partial_elements
    double_test("<abc><otherel></otherel>text</abc>") do |sel|
      assert_equal "text", sel.value
    end
  end

  def test_partial_attributes_in_text
    double_test("<abc myattr='real' someattr='xpto'>text</abc>") do |sel|
      assert_equal "text", sel.value
      assert_equal "real", sel.myattr
    end
  end

  def test_stress_valid_subelements_in_text
    double_test("<abc><otherel><abc></abc></otherel>text</abc>") do |sel|
      assert_equal "<abc>text</abc>", sel.xml_text
    end
  end
end
