require File.dirname(__FILE__) + '/test_helper'
require 'stringio'
require 'rexml/document'
class TestXMLTextElement < Test::Unit::TestCase
  def test_base
    value = 'Some Value'
    el = XMLTextElement.new value
    assert_equal value, el.to_s
    assert_equal value, el.xml_text
  end
  
  def test_partial_export
    io = StringIO.new
    value = 'Some Value'
    el = XMLTextElement.new value
    el.partial_export(io)
    io.pos = 0
    assert_equal value, io.read
  end
  
  def test_elname
    el = XMLTextElement.new 'abc'
    assert_equal '__TEXT__', el.elname
  end
  
  def test_create_xml
    xmlel = Nokogiri::XML::Element.new('abc',Nokogiri::XML::Document.new)
    value = 'Some Value'
    el = XMLTextElement.new value
    el.create_xml(xmlel)
    assert_equal '<abc>'+value+'</abc>', xmlel.to_s
  end
  def test_create_xml_multiple
    xmlel = Nokogiri::XML::Element.new('abc',Nokogiri::XML::Document.new)
    value1 = 'Some Value'
    el1 = XMLTextElement.new value1
    value2 = 'Some Other Value'
    el2 = XMLTextElement.new value2
    el1.create_xml(xmlel)
    el2.create_xml(xmlel)
    assert_equal '<abc>'+value1+value2+'</abc>', xmlel.to_s
  end
end
