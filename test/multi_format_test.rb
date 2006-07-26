require File.dirname(__FILE__) + '/test_helper'
require 'rexml/document'

class FirstFormat < XMLCodec::XMLElement
  xmlformat 'First Format'
end

class FirstRoot < FirstFormat
  elname "root"
  xmlsubel :child
end

class FirstChild < FirstFormat
  elname "child"
  xmlattr :value
end

class SecondFormat < XMLCodec::XMLElement
  xmlformat 'Second Format'
end

class SecondRoot < SecondFormat
  elname "root"
  xmlsubel :child
  xmlsubel :child2
end

class SecondChild < SecondFormat
  elname "child"
  elwithvalue
end

class SecondChild2 < SecondChild
  elname "child2"
  xmlattr :value2
end

# Test what happens when we define two different XML formats with xmlcodec that
# have clashing element names
class TestMultiFormat < Test::Unit::TestCase
  def test_import_first
    value = 'somevalue'
    text = '<root><child value="'+value+'"></child></root>'
    root = FirstFormat.import_xml_text(text)
    assert_kind_of(FirstRoot, root)
    assert_kind_of(FirstChild, root.child)
    assert_equal value, root.child.value
  end

  def test_import_second
    value = 'somevalue'
    text = '<root><child>'+value+'</child></root>'
    root = SecondFormat.import_xml_text(text)
    assert_kind_of(SecondRoot, root)
    assert_kind_of(SecondChild, root.child)
    assert_equal value, root.child.value
  end
  
  def test_double_inheritance
    value = 'somevalue'
    text = '<root><child2 value2="'+value+'">'+value+'</child2></root>'
    root = SecondFormat.import_xml_text(text)
    assert_kind_of(SecondRoot, root)
    assert_kind_of(SecondChild2, root.child2)
    assert_equal value, root.child2.value
    assert_equal value, root.child2.value2
  end
end
