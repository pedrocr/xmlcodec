require 'nokogiri'

module XMLCodec
    VERSION = '0.3.1'
end

require File.dirname(__FILE__) + '/XMLUtils'
require File.dirname(__FILE__) + '/element'
require File.dirname(__FILE__) + '/subelements'
require File.dirname(__FILE__) + '/stream_object_parser'
require File.dirname(__FILE__) + '/stream_parser'
