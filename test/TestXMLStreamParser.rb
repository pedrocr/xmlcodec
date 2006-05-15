$:.unshift File.join(File.dirname(__FILE__), "..")
$-w = true

require 'test/unit'
require 'XMLStreamParser'

class MyStreamListener
	attr_reader :def_id, :def_parent_id
	attr_reader :abc_id, :abc_parent_id
	def element(el)
		case el.name
		when "def"
			@def_id, = el.element_id
			@def_parent_id = el.parent_id
			el.consume
		when "abc"
			@abc_id, = el.element_id
			@abc_parent_id = el.parent_id
			el.consume
		end
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
		listener = MyStreamListener.new
		parser = XMLUtils::XMLStreamParser.new(listener)
		parser.parse(@doc)
		assert_equal(@doc_no_def, parser.content)
		assert_equal(listener.abc_id, listener.def_parent_id)
		assert_equal(0, listener.abc_parent_id)
		assert_equal(1, listener.abc_id)
		assert(listener.def_id > listener.def_parent_id)
	end
end
