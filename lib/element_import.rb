module XMLCodec
  class XMLElement
    public
    # Import the XML into an object from a Nokogiri XML Node or Document or from
    # a string.
    def self.import_xml(obj)
      if obj.instance_of? String
        _import_xml_text(obj)
      elsif obj.instance_of? Nokogiri::XML::Node or 
            obj.instance_of? Nokogiri::XML::Document
        _import_xml_dom(obj)
      else
        nil
      end
    end

    private
    # Import the XML into an object from a Nokogiri XML Node or Document. 
    # This call is recursive and imports any subelements found into the 
    # corresponding objects.
    def self._import_xml_dom(xmlel)
      if xmlel.is_a? Nokogiri::XML::Document
        xmlel = xmlel.root
      end

      elclass = get_element_class(xmlel.name)
      if not elclass
        if class_variable_get(:@@strict_parsing)
    		  raise ElementClassNotFound, "No class defined for element type: '#{e.name}'"  
        else
          return nil
        end
      end
    
      if elclass.allvalue?
        elements = [xmlel.children.map{|c| c.to_xml(:save_with=>0)}.join]
      else
        elements = []
        xmlel.children.each do |e|
          if e.text?
            elements << e.text
          else
            element = _import_xml_dom(e)
            elements << element if element
          end
        end
      end
      
      attributes = {}
      xmlel.attributes.each do |name, attr|
        attributes[name] = attr.value
      end
      
      elclass.new_with_content(attributes, elements)
    end
    
    # Import the XML directly from the text.
    def self._import_xml_text(text)
      parser = XMLStreamObjectParser.new(self)
      parser.parse(text)
      parser.top_element
    end
  end
end
