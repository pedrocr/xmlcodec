module XMLCodec
  class XMLElement
    public
    # Creates the xml for the element inside the parent element. The parent
    # passed should be a Nokogiri XML Node or Document. This call is recursive
    # creating the XML for any subelements. 
    def create_xml(parent)
      xmlel = parent.add_child Nokogiri::XML::Element.new(self.elname.to_s, parent)
      if self.hasvalue?
        xmlel.add_child self.value
      end
      create_xml_attr(xmlel)
      create_xml_subel(xmlel)
      
      if self.has_subelements?
        create_xml_subelements(xmlel)
      end
      
      xmlel
    end

    # Creates the XML subelements
    def create_xml_subel(parent)
      self.class.each_subel do |a|
        if value = self.send(a)
          value.create_xml(parent)
        end
      end
    end
    
    # Create the XML of the SubElements
    def create_xml_subelements(parent)
      self.subelements.create_xml(parent)
    end

    # Creates the XML for the atributes
    def create_xml_attr(parent)
      self.class.each_attr do |a|
        value = self.send(a)
        if value
          parent.set_attribute(a.to_s, value)
        end
      end
    end

    # create the XML text of the element
    def xml_text
      str = create_open_tag
      if self.hasvalue?
        str << XMLCodec::XMLUtils::escape_xml(self.value)
      end
      
      each_subelement do |e|
        str << e.xml_text
      end
      
      str << create_close_tag
      str
    end

    # returns a string with the opening tag for the element
    def create_open_tag
      attrs = {}
      self.class.each_attr do |a|
        value = self.send(a)
        if value
          attrs[a.to_s] = value
        end
      end
      XMLCodec::XMLUtils::create_open_tag(elname.to_s, attrs)
    end
    
    # returns a string with the closing tag for the element
    def create_close_tag
      XMLCodec::XMLUtils::create_close_tag(elname.to_s)
    end
  end
end
