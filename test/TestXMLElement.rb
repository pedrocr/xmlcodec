require File.dirname(__FILE__) + '/test_helper'
require 'rexml/document'

class TestXMLElement < Test::Unit::TestCase
  def test_xmlsubel
    value = 'test'
  
    el = TestElement.new
    sel = SimpleElement.new(value)
    
    el.abc = sel
    assert_equal(sel, el.abc)
    assert_equal(value, sel.value)
    assert_equal(el, sel.__parent)
    
    assert_equal('<abc>'+value+'</abc>', sel.xml_text)
    assert_equal('<subel><abc>'+value+'</abc></subel>', el.xml_text)

    dom = REXML::Document.new
    el.create_xml(dom)
    
    assert_equal 1, dom.elements.size
    eldom = dom.elements['subel']
    assert_not_nil eldom
    assert_equal 1, eldom.elements.size
    
    seldom = eldom.elements['abc']
    assert_not_nil seldom
    assert_equal value, seldom.text
    
    el = TestElement.import_xml(dom)
    assert_equal value, el.abc.value
  end
  
  def test_xmlattr
    value = 'test'
    el = TestElement.new
    
    el.someattr = value
    assert_equal(value, el.someattr) 
    
    assert_equal("<subel someattr='"+value+"'></subel>", el.xml_text)
    
    dom = REXML::Document.new
    el.create_xml(dom)
    
    assert_equal 1, dom.elements.size
    eldom = dom.elements['subel']
    assert_not_nil eldom
    assert_equal value, eldom.attributes['someattr']
    
    el = TestElement.import_xml(dom)
    assert_equal value, el.someattr
  end
  
  def test_xmlsubelements
    value = 'test'
    el = SubelElement.new
    sel = SimpleElement.new(value)
    
    el.subelements << sel
    assert_equal(sel, el.subelements[0])
    assert_equal(el, sel.__parent)
    
    assert_equal('<subels><abc>'+value+'</abc></subels>', el.xml_text)
    
    dom = REXML::Document.new
    el.create_xml(dom)
    
    assert_equal 1, dom.elements.size
    eldom = dom.elements['subels']
    assert_not_nil eldom
    assert_equal 1, eldom.elements.size
    
    seldom = eldom.elements['abc']
    assert_not_nil seldom
    assert_equal value, seldom.text
    
    el = SubelElement.import_xml(dom)
    assert_equal 1, el.subelements.size
    assert_equal value, el.subelements[0].value
  end
  
  # Test using "somelement << addsomething" instead of 
  # "somelement.subelements << addsomething"
  def test_xmlsubelements_direct
    value = 'test'
    el = SubelElement.new
    sel = SimpleElement.new(value)
    
    el << sel
    assert_equal(sel, el.subelements[0])
  end
  
  def test_find_first
    value = 'test'
    el = SubelElement.new
    sel = SimpleElement.new(value)
    
    el << sel
    assert_equal(sel, el.find_first_named('abc'))
    assert_equal(sel, el['abc'])
  end
  
  def test_find_all
    value = 'test'
    el = SubelElement.new
    sel = SimpleElement.new(value)
    sel2 = SimpleElement.new(value)
    
    el << sel
    el << sel2
    assert_equal([sel,sel2], el.find_all_named('abc'))
  end
  
  def test_find_all_with_texts
    value = 'test'
    el = SubelElement.new
    sel = SimpleElement.new(value)
    sel2 = SimpleElement.new(value)
    
    el << sel
    el << 'some text'
    el << sel2
    assert_equal([sel,sel2], el.find_all_named('abc'))
  end
  
  def test_xmlsubel_mult
    value1 = 'test'
    value2 = 'test2'
    el = SubelMultElement.new
    sel1 = SimpleElement.new(value1)
    sel2 = SimpleElement.new(value2)
    
    el.abc << sel1
    el.abc << sel2
    
    assert_equal(sel1, el.abc[0])
    assert_equal(el, sel1.__parent)
    assert_equal(el, sel2.__parent)
    
    assert_equal('<mult><abc>'+value1+'</abc><abc>'+value2+'</abc></mult>', el.xml_text)
    
    dom = REXML::Document.new
    el.create_xml(dom)
    
    assert_equal 1, dom.elements.size
    eldom = dom.elements['mult']
    assert_not_nil eldom
    assert_equal 2, eldom.elements.size
    
    [value1, value2].each_with_index do |value, index|
      seldom = eldom.elements[index+1]
      assert_not_nil seldom
      assert_equal value, seldom.text
      assert_equal 'abc', seldom.name
    end
    
    el = SubelMultElement.import_xml(dom)
    assert_equal 2, el.abc.size
    assert_equal value1, el.abc[0].value
    assert_equal value2, el.abc[1].value
  end
  
  def test_delete_element_simple
    el = TestElement.new
    sel = SimpleElement.new('')
    el.abc = sel
    assert_equal sel, el.abc
    
    el.delete_element(sel)
    assert_nil el.abc
  end
  
  def test_delete_element_double
    el = TestElement.new
    sel1 = SimpleElement.new('')
    sel2 = SimpleElement2.new('')
    el.abc = sel1
    el.abc2 = sel2
    
    assert_equal sel1, el.abc
    assert_equal sel2, el.abc2
    
    el.delete_element(sel1)
    assert_nil el.abc
    assert_equal sel2, el.abc2
  end
  
  def test_delete_element_multiple
    el = SubelMultElement.new
    sel = SimpleElement.new('')
    el.abc << sel
    assert_equal sel, el.abc[0]
    
    el.delete_element(sel)
    assert_nil el.abc[0]
  end
  
  def test_delete_element_subelements
    el = SubelElement.new
    sel1 = SimpleElement.new('')
    sel2 = SimpleElement.new('')
    el.subelements << sel1
    el.subelements << sel2
    
    assert_equal 2, el.subelements.size
    assert_equal sel1, el.subelements[0]
    assert_equal sel2, el.subelements[1]
    
    el.delete_element(sel1)
    assert_equal 1, el.subelements.size
    assert_equal sel2, el.subelements[0]
    
    el.delete_element(sel2)
    assert_equal 0, el.subelements.size
    assert_nil el.subelements[0]
  end
  
  def test_elwithvalue_methods
    v = 'Some Value'
    
    el = ValueElement.new
    el.value = v
    assert_equal v, el.value
    
    el = ValueElement.new(v)
    assert_equal v, el.value
  end
end
