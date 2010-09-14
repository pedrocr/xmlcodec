require File.dirname(__FILE__) + '/test_helper'

class TestPartialExport < Test::Unit::TestCase
  def validate_well_formed(filename)
    assert(system("xmllint --version > /dev/null 2>&1"), 
           "xmllint utility not installed"+
           "(on ubuntu/debian install package libxml2-utils)")      
		assert(system("xmllint #{filename} >/dev/null"), 
           "Validation failed for #{filename}")
	end

  def compare_xpath(value, filename, path)
		assert_equal(value.strip, XMLUtils::select_path(path, filename).strip)
	end

  def test_simple
    path = filepath('test_partial_export_simple.xml')
    value = "somevalue"
  
    file = File.open(path, "w")
    sel = SimpleElement.new(value)
    sel.partial_export(file)
    file.close
  
    validate_well_formed(path)
    compare_xpath(value, path, "/abc")
  end
  
  def test_double
    value = 'somevalue'
    path = filepath('test_partial_export_double.xml')
    
    file = File.open(path, "w")
    sel = SimpleElement.new(value)
    el = TestElement.new
    el.abc = sel
    
    sel.partial_export(file)
    el.end_partial_export(file)
    file.close
    
    validate_well_formed(path)
    compare_xpath(value, path, "/subel/abc")
  end
  
  def test_triple
    value = 'somevalue'
    path = filepath('test_partial_export_double.xml')
    
    file = File.open(path, "w")
    sel = SimpleElement.new(value)
    el1 = TestElement.new
    el2 = TestElement.new
    el1.subel = el2
    el2.abc = sel
    
    sel.partial_export(file)
    el1.end_partial_export(file)
    file.close
    
    validate_well_formed(path)
    compare_xpath(value, path, "/subel/subel/abc")
  end
  
  def test_attr
    value = 'somevalue'
    path = filepath('test_partial_export_double.xml')
    
    file = File.open(path, "w")
    el = TestElement.new
    el.someattr = value
    
    el.partial_export(file)
    file.close
    
    compare_xpath(value, path, "/subel/@someattr")
  end
  
  def test_mult
    value1 = 'somevalue1'
    value2 = 'somevalue2'
    path = filepath('test_partial_export_mult.xml')
    
    file = File.open(path, "w")
    sel1 = SimpleElement.new(value1)
    sel2 = SimpleElement.new(value2)
    
    el = SubelMultElement.new
    el.abc << sel1    
    sel1.partial_export(file)
    
    el.abc << sel2
    sel2.partial_export(file)
    el.end_partial_export(file)
    
    file.close
    
    validate_well_formed(path)
    compare_xpath(value1, path, "/mult/abc[1]")
    compare_xpath(value2, path, "/mult/abc[2]")
  end
  
  def test_subelements
    value1 = 'somevalue1'
    value2 = 'somevalue2'
    path = filepath('test_partial_export_subelements.xml')
    
    file = File.open(path, "w")
    sel1 = SimpleElement.new(value1)
    sel2 = SimpleElement.new(value2)
    
    el = SubelElement.new
    el.subelements << sel1    
    sel1.partial_export(file)
    
    el.subelements << sel2
    sel2.partial_export(file)
    el.end_partial_export(file)
    
    file.close
    
    validate_well_formed(path)
    compare_xpath(value1, path, "/subels/abc[1]")
    compare_xpath(value2, path, "/subels/abc[2]")
  end
  
  def test_subelements_multiple
    value1 = 'somevalue1'
    value2 = 'somevalue2'
    path = filepath('test_partial_export_subelements2.xml')
    
    file = File.open(path, "w")
    sel1 = SimpleElement.new(value1)
    sel2 = SimpleElement.new(value2)
    
    el = SubelElement.new
    el.subelements << sel1
    el.subelements << sel2
    el.partial_export(file)
    
    file.close
    
    validate_well_formed(path)
    compare_xpath(value1, path, "/subels/abc[1]")
    compare_xpath(value2, path, "/subels/abc[2]")
  end
  
  def test_recursive
    path = filepath('test_partial_export_recursive.xml')
    file = File.open(path, "w")
    
    value = 'somevalue'
  
    rec1 = Recursive.new
    rec1.start_partial_export(file)
    
    rec2 = Recursive.new
    rec1.recursive << rec2
    rec2.start_partial_export(file)
    
    rec3 = Recursive.new
    rec2.recursive << rec3
    rec3.start_partial_export(file)
    
    sel = SimpleElement.new(value)
    sel.start_partial_export(file)
    rec3.abc = sel
    
    rec1.end_partial_export(file)
    
    file.close
    validate_well_formed(path)
  end
end
