require 'simplecov'
SimpleCov.start

require 'test/unit'
require 'tmpdir'
require File.dirname(__FILE__) + '/../lib/xmlcodec'
require File.dirname(__FILE__) + '/simple_objects'


class Test::Unit::TestCase
  def with_temp_file
    callname = Regexp.new("`(.*?)'").match(caller[0])[1]
    @temp_path = File.join(Dir::tmpdir, callname+".xml")
    File.open(@temp_path, "w") do |file|
      yield file
    end
  end

  def validate_well_formed
    assert(system("xmllint --version > /dev/null 2>&1"), 
           "xmllint utility not installed"+
           "(on ubuntu/debian install package libxml2-utils)")      
		assert(system("xmllint #{@temp_path} >/dev/null"), 
           "Validation failed for #{@temp_path}")
	end

  def compare_xpath(value, path)
		assert_equal(value.strip, XMLCodec::XMLUtils::select_path(path, @temp_path).strip)
	end
end
