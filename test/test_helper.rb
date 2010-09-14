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
    filename = filename || @temp_path
    assert(system("xmllint --version > /dev/null 2>&1"), 
           "xmllint utility not installed"+
           "(on ubuntu/debian install package libxml2-utils)")      
		assert(system("xmllint #{filename} >/dev/null"), 
           "Validation failed for #{filename}")
	end

  def compare_xpath(value, path)
    filename = filename || @temp_path
		assert_equal(value.strip, XMLUtils::select_path(path, filename).strip)
	end
end
