module XMLCodec
  class XMLElement
    private
    # Add a xmlsubel type attribute
    def self.xmlsubel(name) #:doc:
      name = name.to_sym
      self._xmlsubel(name)
      attr_reader name
      define_method((name.to_s+"=").to_sym) { |value|
        if value.is_a? String or value.is_a? Fixnum
          value = self.class.get_element_class(name).new(value)
        end
        value.__parent = self if value
        instance_variable_set "@#{name}", value
      }
    end
    
    # Add a xmlsubel_mult type attribute (wrapper around attr_accessor)
    def self.xmlsubel_mult(name) #:doc:
      name = name.to_sym
      self._xmlsubel(name)
      self.xmlsubelmultiples << name
      define_method(name){
        if not self.instance_variables.index("@#{name}".to_sym)
          instance_variable_set "@#{name}", XMLSubElements.new(self)
        end
        instance_variable_get "@#{name}"
      }
    end

    # Add a name as being a subelement (mult or single)
    def self._xmlsubel(name)
      self.xmlsubels << name
    end

    # Class level variable to hold the list of subelements
    def self.xmlsubels
      @xmlsubels ||=[]
    end
    
    # Class level variable to hold the list of subelements that are multiple
    def self.xmlsubelmultiples
      @xmlsubelmultiples ||=[]
    end
    
    # Iterates over the object's XML subelements
    def self.each_subel
      if not self.instance_variables.index("@__subel_names".to_sym)
        names = []
        # Iterate all the superclasses that are still children of XMLElement
        # and iterate each of the subelements
        c = self
        while c.ancestors.index(XMLCodec::XMLElement)
          names += c.xmlsubels
          c = c.superclass
        end
        @__subel_names = names
      end
      @__subel_names.each {|name| yield name}
    end

    # Iterate all the superclasses that are still children of XMLElement
    # and check if any of them have the subelement mult defined
    def self.subel_mult?(element)
      if not self.instance_variables.index("@__subel_mult_names".to_sym)
        names = []
        c = self
        while c.ancestors.index(XMLCodec::XMLElement)
          names += c.xmlsubelmultiples
          c = c.superclass
        end
        @__subel_mult_names = names
      end
      return @__subel_mult_names.index(element)? true : false
    end
    
    # Iterate all the superclasses that are still children of XMLElement
    # and check if any of them have any subelements handled by this class
    def get_subel(elclass)
      names = elclass.get_elnames
      c = self.class
      while c.ancestors.index(XMLCodec::XMLElement)
        names.each do |name|
          if c.xmlsubels.index(name.to_sym)
            return names[0].to_sym
          end
        end
        c = c.superclass
      end
      return nil
    end
  end
end
