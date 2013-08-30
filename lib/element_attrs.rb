module XMLCodec
  class XMLElement
    private
    # Add a xmlattr type attribute (wrapper around attr_accessor)
    def self.xmlattr(name) #:doc:
      self.xmlattrs << name.to_sym
      attr_accessor name
    end

    # Class level variable that holds the list of attributes
    def self.xmlattrs
      @xmlattrs ||=[]
    end

    # Iterates over the object's XML atributes
    def self.each_attr    
      attr_names.each {|name| yield name}
    end

    def self.attr_names
      if not self.instance_variables.index("@__attr_names".to_sym)
        names = []
        # Iterate all the superclasses that are still children of XMLElement
        # and iterate each of the attributes
        c = self
        while c.ancestors.index(XMLCodec::XMLElement)
          names += c.xmlattrs
          c = c.superclass
        end
        @__attr_names = names
      end
      
      @__attr_names
    end
  end
end
