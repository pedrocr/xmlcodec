include XMLCodec

class StrictBaseFormat < XMLElement
  xmlformat 'Base Format'
  xml_strict_parsing
end

class BaseFormat < XMLElement
  xmlformat 'Base Format'
end

class SimpleElement < BaseFormat
  elwithvalue
  elname 'abc'
end

class SimpleElement2 < BaseFormat
  elwithvalue
  elname 'abc1'
end

class SimpleElementMultName < BaseFormat
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

class TestElement < BaseFormat
  elname 'subel'
  xmlsubel :abc
  xmlsubel :abc2
  xmlsubel :subel
  xmlattr :someattr
  xmlattr 'anotherattr'
end

class SubelElement < BaseFormat
  elname 'subels'
  xmlsubelements
end

class SubelMultElement < BaseFormat
  elname 'mult'
  xmlsubel_mult :abc
  xmlsubel_mult 'abc2' # Use a string and a symbol so that both are checked
end

class Recursive < BaseFormat
  elname 'recursive'
  xmlsubel :abc
  xmlsubel_mult :recursive
end

class ValueParent < BaseFormat
  elname 'valueparent'
  xmlsubel 'valueelement'
end

class ValueElement < BaseFormat
  elwithvalue
  elname 'valueelement'
end
