require File.dirname(__FILE__) + '/test_helper.rb'
require 'nokogiri'

class ConsumeAllAsTextTest < Test::Unit::TestCase
  class BaseFormat < XMLElement
    xmlformat 'Base Format'
  end

  class SimpleElement < BaseFormat
    elallvalue
    elname 'abc'
    xmlattr :myattr
  end

  double_import_test(:test_import_elements, BaseFormat,
              "<abc myattr='real'><otherel>foo</otherel>text</abc>") do |sel|
    assert_equal 'real', sel.myattr
    assert_equal "<otherel>foo</otherel>text", sel.value
  end

  double_import_test(:test_nested_elements, BaseFormat,
              "<abc myattr='real'><otherel><abc>foo</abc></otherel>text</abc>") do |sel|
    assert_equal 'real', sel.myattr
    assert_equal "<otherel><abc>foo</abc></otherel>text", sel.value
  end
end
