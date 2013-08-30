require File.dirname(__FILE__) + '/test_helper.rb'
require 'nokogiri'

class TestPartialImport < Test::Unit::TestCase
  class PartialBaseFormat < XMLElement
    xmlformat 'Base Format'
  end

  class PartialSimpleElement < PartialBaseFormat
    elwithvalue
    elname 'abc'
    xmlattr :myattr
  end

  double_import_test(:test_partial_elements, PartialBaseFormat,
              "<abc><otherel></otherel>text</abc>") do |sel|
    assert_equal "text", sel.value
  end

  double_import_test(:test_partial_attributes_in_text, PartialBaseFormat,
              "<abc myattr='real' someattr='xpto'>text</abc>") do |sel|
    assert_equal "text", sel.value
    assert_equal "real", sel.myattr
  end

  double_import_test(:test_stress_valid_subelements_in_text, PartialBaseFormat,
              "<abc><otherel><abc></abc></otherel>text</abc>") do |sel|
    assert_equal "<abc>text</abc>", sel.xml_text
  end
end
