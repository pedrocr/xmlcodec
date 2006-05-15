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
end
