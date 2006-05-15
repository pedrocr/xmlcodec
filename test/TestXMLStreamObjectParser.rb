require "test/unit"
require "XMLStreamObjectParser"
require 'simple_objects.rb'

include XMLCodec

class MyStreamListener
  attr_reader :abc, :subels, :mult, :subel
  def el_abc(el)
    @abc = el.get_object
  end
  
  def el_subels(el)
    @subels = el.get_object
  end
  
  def el_mult(el)
    @mult = el.get_object
  end
  
  def el_subel(el)
    @subel = el.get_object
  end
end

class MyConsumingStreamListener
  attr_reader :abc

  def el_abc(el)
    el.consume
    @abc = el.get_object
  end
end

class TestXMLStreamObjectParser < Test::Unit::TestCase
  def initialize(*args)
    super(*args)
    
    @test_file = "test_ead_stream_object_parser.xml"
  end

  def test_simple
    value = 'somevalue'
    file = '<abc>'+value+'</abc>'
    
    listener = MyStreamListener.new
    parser = XMLStreamObjectParser.new(listener)
    parser.parse(file)
    el = listener.abc
    assert_equal el.value, value
  end
  
  def test_attr
    value = 'somevalue'
    attrvalue = 'the attr value'
    file = '<subel someattr="'+attrvalue+'"><abc>'+value+'</abc></subel>'
    
    listener = MyStreamListener.new
    parser = XMLStreamObjectParser.new(listener)
    parser.parse(file)
    
    el = listener.abc
    assert_equal el.value, value
    
    subel = parser.top_element
    assert_equal el, subel.abc
    assert_equal attrvalue, subel.someattr
  end
  
  def test_multiple_names
    
  end
  
  def test_mult
    value = 'somevalue'
    file = '<mult><abc>'+value+'</abc></mult>'
    
    listener = MyStreamListener.new
    parser = XMLStreamObjectParser.new(listener)
    parser.parse(file)
    
    el = listener.abc
    assert_equal el.value, value
    assert_equal el, parser.top_element.abc[0]
  end
  
  def test_subelements
    value = 'somevalue'
    file = '<subels><abc>'+value+'</abc></subels>'
    
    listener = MyStreamListener.new
    parser = XMLStreamObjectParser.new(listener)
    parser.parse(file)
    
    el = listener.abc
    assert_equal el.value, value
    assert_equal el, parser.top_element.subelements[0]
  end
  
  def test_consume_mult
    value = 'somevalue'
    file = '<subel><abc>'+value+'</abc></subel>'
    
    listener = MyConsumingStreamListener.new
    parser = XMLStreamObjectParser.new(listener)
    parser.parse(file)
    
    el = listener.abc
    assert_equal el.value, value
    assert_nil parser.top_element.abc
  end
  
  def test_multnames_subelements
    value1 = 'somevalue1'
    value2 = 'somevalue2'
    file = '<subels><abc2>'+value1+'</abc2><abc3>'+value2+'</abc3></subels>'
  
    listener = MyStreamListener.new
    parser = XMLStreamObjectParser.new(listener)
    parser.parse(file)
    
    el = listener.subels
    assert_equal 2, el.subelements.size
    [value1, value2].each_with_index do |value, index|
      assert_kind_of SimpleElementMultName, el.subelements[index]
      assert_equal value, el.subelements[index].value
    end
  end
  
  def test_multnames_subel_mult
    value1 = 'somevalue1'
    value2 = 'somevalue2'
    file = '<mult><abc2>'+value1+'</abc2><abc3>'+value2+'</abc3></mult>'
  
    listener = MyStreamListener.new
    parser = XMLStreamObjectParser.new(listener)
    parser.parse(file)
    
    el = listener.mult
    assert_equal 2, el.abc2.size
    [value1, value2].each_with_index do |value, index|
      assert_kind_of SimpleElementMultName, el.abc2[index]
      assert_equal value, el.abc2[index].value
    end
  end
  
  def test_multnames_subel
    value = 'somevalue'
    file = '<subel><abc3>'+value+'</abc3></subel>'
  
    listener = MyStreamListener.new
    parser = XMLStreamObjectParser.new(listener)
    parser.parse(file)
    
    el = listener.subel
    assert_not_nil el.abc2
    assert_kind_of SimpleElementMultName, el.abc2
    assert_equal value, el.abc2.value
  end
end
