$:.unshift File.join(File.dirname(__FILE__), "..")

require 'test/unit'
require 'XMLUtils'

class TestXMLUtils < Test::Unit::TestCase
  def test_create_open_tag
    tag = XMLUtils::create_open_tag("name", {"arg1" => "val1", "arg2" => "val2"})
    assert_equal("<name arg1='val1' arg2='val2'>", tag)  
  end
  
  def test_escape_xml
    assert_equal '&lt; abc', XMLUtils::escape_xml('< abc')
    assert_equal '&gt; abc', XMLUtils::escape_xml('> abc')
    assert_equal '&amp; abc', XMLUtils::escape_xml('& abc')
  end
  
  def test_get_xpath
    opts = {}
    assert_xpath_equal('abc', '//xpto', '<xpto>abc<xpto>')
    
    assert_xpath_equal('abc', '//xpto', '<xpto>abc<xpto2>foo</xpto2><xpto>')
    
    opts[:with_attrs] = true
    opts[:recursive] = false
    opts[:multiple] = false
    assert_xpath_equal('attr1 abc', '//xpto', '<xpto attr1="attr1">abc<xpto2>foo</xpto2><xpto>', opts)
    
    opts[:with_attrs] = false
    opts[:recursive] = true
    opts[:multiple] = false
    assert_xpath_equal('abc foo', '//xpto', '<xpto>abc<xpto2 attr1="attr1">foo</xpto2><xpto>', opts)
    
    opts[:with_attrs] = true
    opts[:recursive] = true
    opts[:multiple] = false
    assert_xpath_equal('abc attr1 foo', '//xpto', '<xpto>abc<xpto2 attr1="attr1">foo</xpto2><xpto>', opts)
    
    opts[:with_attrs] = false
    opts[:recursive] = false
    opts[:multiple] = true
    assert_xpath_equal('abc foo', '//xpto', '<xpto>abc<xpto attr1="attr1">foo</xpto><xpto>', opts)
  end
  
  def assert_xpath_equal(result, path, xml, opts={})
    assert_equal result, XMLUtils::get_xpath(path, xml, opts)
    assert_equal result, XMLUtils::get_xpath(path, StringIO.new(xml), opts)
    assert_equal result, XMLUtils::get_xpath(path, REXML::Document.new(xml), opts)
  end
end
