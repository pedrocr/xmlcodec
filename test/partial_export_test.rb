require File.dirname(__FILE__) + '/test_helper'

class TestPartialExport < Test::Unit::TestCase
  def test_simple
    value = "somevalue"
  
    with_temp_file do |file|
      sel = SimpleElement.new(value)
      sel.partial_export(file)
    end
      
    validate_well_formed
    compare_xpath(value, "/abc")
  end
  
  def test_double
    value = 'somevalue'
    
    with_temp_file do |file|
      sel = SimpleElement.new(value)
      el = TestElement.new
      el.abc = sel
      
      sel.partial_export(file)
      el.end_partial_export(file)
    end
    
    validate_well_formed
    compare_xpath(value, "/subel/abc")
  end
  
  def test_triple
    value = 'somevalue'
    
    with_temp_file do |file|
      sel = SimpleElement.new(value)
      el1 = TestElement.new
      el2 = TestElement.new
      el1.subel = el2
      el2.abc = sel
      
      sel.partial_export(file)
      el1.end_partial_export(file)
    end
    
    validate_well_formed
    compare_xpath(value, "/subel/subel/abc")
  end
  
  def test_attr
    value = 'somevalue'
    
    with_temp_file do |file|
      el = TestElement.new
      el.someattr = value

      el.partial_export(file)
    end
    
    compare_xpath(value, "/subel/@someattr")
  end
  
  def test_mult
    value1 = 'somevalue1'
    value2 = 'somevalue2'
    
    with_temp_file do |file|
      sel1 = SimpleElement.new(value1)
      sel2 = SimpleElement.new(value2)
      
      el = SubelMultElement.new
      el.abc << sel1    
      sel1.partial_export(file)
      
      el.abc << sel2
      sel2.partial_export(file)
      el.end_partial_export(file)
    end
    
    validate_well_formed
    compare_xpath(value1, "/mult/abc[1]")
    compare_xpath(value2, "/mult/abc[2]")
  end
  
  def test_subelements
    value1 = 'somevalue1'
    value2 = 'somevalue2'
    
    with_temp_file do |file|
    sel1 = SimpleElement.new(value1)
    sel2 = SimpleElement.new(value2)
    
    el = SubelElement.new
    el.subelements << sel1    
    sel1.partial_export(file)
    
    el.subelements << sel2
    sel2.partial_export(file)
    el.end_partial_export(file)
    
    end
    
    validate_well_formed
    compare_xpath(value1, "/subels/abc[1]")
    compare_xpath(value2, "/subels/abc[2]")
  end
  
  def test_subelements_multiple
    value1 = 'somevalue1'
    value2 = 'somevalue2'
    
    with_temp_file do |file|
      sel1 = SimpleElement.new(value1)
      sel2 = SimpleElement.new(value2)
      
      el = SubelElement.new
      el.subelements << sel1
      el.subelements << sel2
      el.partial_export(file)
    end
    
    validate_well_formed
    compare_xpath(value1, "/subels/abc[1]")
    compare_xpath(value2, "/subels/abc[2]")
  end
  
  def test_recursive
    value = 'somevalue'

    with_temp_file do |file|
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
    end
    validate_well_formed
  end
end
