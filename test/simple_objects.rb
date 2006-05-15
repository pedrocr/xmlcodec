require 'XMLElement'
include XMLCodec

class SimpleElement < XMLElement
  elwithvalue
  elname 'abc'
end

class SimpleElement2 < XMLElement
  elwithvalue
  elname 'abc1'
end

class SimpleElementMultName < XMLElement
  elwithvalue
  elnames 'abc2', 'abc3'
  
  attr_writer :set_elname
    
  alias_method :oldelname, :elname
  def elname
    if instance_variables.index("@set_elname")
      return @set_elname
    else
      return 'abc2'
    end
  end
end

class TestElement < XMLElement
  elname 'subel'
  xmlsubel :abc
  xmlsubel :abc2
  xmlsubel :subel
  xmlattr :someattr
end

class SubelElement < XMLElement
  elname 'subels'
  xmlsubelements
end

class SubelMultElement < XMLElement
  elname 'mult'
  xmlsubel_mult :abc
  xmlsubel_mult :abc2
end
