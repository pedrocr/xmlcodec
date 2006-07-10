$:.unshift File.join(File.dirname(__FILE__), "..")
$-w = true

require 'test/unit'
require 'XMLStreamParser'

class MyXMLStreamListener
  attr_reader :def_id, :def_parent_id
  attr_reader :abc_id, :abc_parent_id
  
  def el_def(el)
    @def_id, = el.element_id
    @def_parent_id = el.parent_id
    el.consume
  end
  
  def el_abc(el)
    @abc_id, = el.element_id
    @abc_parent_id = el.parent_id
    el.consume
  end
end

class TestXMLStreamParser < Test::Unit::TestCase
  def initialize(*args)
    super(*args)
    @doc = "<abc attr1='1' attr2='2'>abc<xpto attr1='a'></xpto><def><x></x></def></abc>"
    @doc_no_def = "<abc attr1='1' attr2='2'>abc<xpto attr1='a'></xpto></abc>"
  end

  def test_total_parse
    parser = XMLUtils::XMLStreamParser.new
    parser.parse(@doc)
    assert_equal(@doc, parser.content)
  end
  
  def test_consumed_parse
    listener = MyXMLStreamListener.new
    parser = XMLUtils::XMLStreamParser.new(listener)
    parser.parse(@doc)
    assert_equal(@doc_no_def, parser.content)
    assert_equal(listener.abc_id, listener.def_parent_id)
    assert_equal(0, listener.abc_parent_id)
    assert_equal(1, listener.abc_id)
    assert(listener.def_id > listener.def_parent_id)
  end
  
  def test_entities
    edoc = '<root>&amp;</root>'
    
    parser = XMLUtils::XMLStreamParser.new
    parser.parse(edoc)
    assert_equal(edoc, parser.content)
  end
end
