require 'test/unit'
require 'tmpdir'
require File.dirname(__FILE__) + '/../lib/xmlcodec'
require File.dirname(__FILE__) + '/simple_objects'


class Test::Unit::TestCase
  def filepath(filename)
    File.join(Dir::tmpdir, filename)
  end
end
