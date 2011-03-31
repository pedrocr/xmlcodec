require File.dirname(__FILE__) + '/test_helper'
require 'tmpdir'

class TestXMLUtils < Test::Unit::TestCase
  def test_create_open_tag
    tag = XMLCodec::XMLUtils::create_open_tag("name", {"arg1" => "val1", "arg2" => "val2"})
    assert_equal("<name arg1='val1' arg2='val2'>", tag)  
  end
  
  def test_escape_xml
    assert_equal '&lt; abc', XMLCodec::XMLUtils::escape_xml('< abc')
    assert_equal '&gt; abc', XMLCodec::XMLUtils::escape_xml('> abc')
    assert_equal '&amp; abc', XMLCodec::XMLUtils::escape_xml('& abc')
    assert_equal 'abc', XMLCodec::XMLUtils::escape_xml('abc')
  end
  
  def test_count_elements
    text = '<root><abc/><abc/></root>'
    filename = File.join(Dir::tmpdir, 'test_count_elements.xml')
    f = File.open(filename, 'w')
    f << text
    f.close
    assert_equal 2, XMLCodec::XMLUtils::count_elements('//abc', filename)
  end
  
  def test_element_exists
    text = '<root><abc/><abc/></root>'
    filename = File.join(Dir::tmpdir, 'test_element_exists.xml')
    f = File.open(filename, 'w')
    f << text
    f.close
    assert XMLCodec::XMLUtils::element_exists('//abc', filename)
  end
end
