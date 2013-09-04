require 'nokogiri'

module XMLCodec
    VERSION = '0.3.2'
end

require File.join(File.dirname(__FILE__),'XMLUtils')
require File.join(File.dirname(__FILE__),'element')
require File.join(File.dirname(__FILE__),'element_creation')
require File.join(File.dirname(__FILE__),'element_partial_export')
require File.join(File.dirname(__FILE__),'element_import')
require File.join(File.dirname(__FILE__),'element_export')
require File.join(File.dirname(__FILE__),'element_attrs')
require File.join(File.dirname(__FILE__),'element_value')
require File.join(File.dirname(__FILE__),'element_subel')
require File.join(File.dirname(__FILE__),'element_subelements')
require File.join(File.dirname(__FILE__),'subelements')
require File.join(File.dirname(__FILE__),'stream_object_parser')
require File.join(File.dirname(__FILE__),'stream_parser')
