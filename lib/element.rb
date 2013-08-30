module XMLCodec
  class ElementClassNotFound < RuntimeError
  end

  class ElementAttributeNotFound < RuntimeError
  end

  # This class should be inherited from to create classes that are able to
  # import and export XML elements and their children. It provides three main
  # functions: xmlattr, xmlsubel and xmlsubel_mult.
  #
  # To create an importer/exporter for a XML format all that's needed is to 
  # create a class for each of the elements and then declare their atributes and
  # subelements.
  #
  # Two other functions have an important role. elname declares the name of the
  # XML element the class represents. elwithvalue declares that the element
  # has no subelements and includes only text content.
  #
  # After the class is defined import_xml can be used to import the content from
  # a Nokogiri Element or Document and create_xml can be used to create the XML DOM
  # of the element as a child to a Nokogiri Element or Document. For big documents
  # these are usually too slow and memory hungry, using xml_text to export to 
  # XML and import_xml_text to import XML are probably better ideas. 
  # import_xml_text is just a utility function around XMLStreamObjectParser,
  # that allow more flexible stream parsing of XML files while still using the
  # same XMLElement objects.
  class XMLElement
    INDENT_STR = '  '
    CACHE = {}
  
    attr_accessor :element_id, :parent_id, :__xml_text
    attr_accessor :__parent
    ## A xmlsubel is any subelement of a given element

  private
    # Defines a new xml format (like XHTML or DocBook). This should be used in 
    # a class that's the super class of all the elements of a format
    def self.xmlformat(name=nil)
      class_variable_set(:@@elclasses, {})
      class_variable_set(:@@strict_parsing, false)
    end

    def self.xml_strict_parsing
      class_variable_set(:@@strict_parsing, true)
    end
    
    def self.elclasses
      class_variable_get(:@@elclasses)
    end
    
    # Sets the element name for the element
    def self.elname(name)
      elnames(name)
    end
    
    # Sets several element names for the element
    def self.elnames(*names)
      define_method(:elname){names[0].to_sym}

      eln = get_elnames
      names.each {|n| eln << n}
      names.each {|n| elclasses[n.to_sym] = self}
    end
    
    # Returns the list of element names for the element
    def self.get_elnames
      @elnames||=[]
    end
    
    # Which level of indentation are we in?
    #
    # This is currently disabled until I get around to implementing proper and 
    # tested indent support.
    #def indent_level
    #  if not self.instance_variables.index '@indent_level'.to_sym
    #    curr = self
    #    level = 0
    #    while curr = curr.__parent
    #      level +=1
    #    end
    #    @indent_level = level 
    #  end
    #  @indent_level
    #end
    
    # Iterate all of the subelements
    # We copy everything into an array and iterate that because #each doesn't
    # like it when elements are deleted while it's iterating.
    def each_subelement
      arr = []
    
      self.class.each_subel do |a|  
        if value = self.send(a)
          if self.class.subel_mult? a
            value.each {|e| arr << e}
          else
            arr << value
          end
        end
      end
      
      if has_subelements?
        self.subelements.each{|e| arr << e}
      end
      
      arr.each {|e| yield e}
    end
    
  public
    # Remove the given subelement from the element
    def delete_element(element)
      self.class.each_subel do |a|  
        value = self.send(a)
        if self.class.subel_mult? a
          value.delete_element(element)
        else
          self.send(a.to_s+'=', nil) if value == element
        end
      end
      
      if has_subelements?
        @subelements.delete_element(element)
      end 
    end
  
    # Calculate the text indentation to use for this level. Returns a string
    # with the whitespace that should precede every line. Extra levels of
    # indentation can be passed so that a caller can calculate the whitespace
    # to indent an element X levels deeper than this one.
    #
    # This is currently disabled until I get around to implementing proper and 
    # tested indent support.
    #def indentation(extra=0)
    #  INDENT_STR*(indent_level+extra)
    #end
  
    # Gets the class for a certain element name.
    def self.get_element_class(name)
      cl = elclasses[name.to_sym]
  	  if not cl and class_variable_get(:@@strict_parsing)
  		  raise ElementClassNotFound, "No class defined for element type: '" + name.to_s + "'"
  		end
  		cl
    end
    
    # Gets the possible element names for a certain element.
    def self.get_element_names(name)
      get_element_class(name).get_elnames
    end
  end
end
