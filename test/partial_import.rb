require File.dirname(__FILE__) + '/test_helper.rb'

class BaseFormat < XMLElement
  xmlformat 'Base Format'
end

class SimpleElement < BaseFormat
  elwithvalue
  elname 'abc'
  xmlattr 'myattr'
end

class TestPartialImport < Test::Unit::TestCase
  def test_partial_elements
    sel = BaseFormat.import_xml_text "<abc><otherel></otherel>text</abc>"
    assert_equal "text", sel.value
  end

  def test_partial_attributes
    sel = BaseFormat.import_xml_text "<abc myattr='real' someattr='xpto'>text</abc>"
    assert_equal "text", sel.value
    assert_equal "real", sel.myattr
  end
end
