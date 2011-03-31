module XMLCodec
  class ElementClassNotFound < RuntimeError
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
    # Class level variable to hold the list of subelements
    def self.xmlsubels
      @xmlsubels ||=[]
    end
    
    # Class level variable to hold the list of subelements that are multiple
    def self.xmlsubelmultiples
      @xmlsubelmultiples ||=[]
    end
    
    # Class level variable that holds the list of attributes
    def self.xmlattrs
      @xmlattrs ||=[]
    end
  
    # Add a name as being a subelement (mult or single)
    def self._xmlsubel(name)
      self.xmlsubels << name
    end
    
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
        if not self.instance_variables.index("@#{name}")
          instance_variable_set "@#{name}", XMLSubElements.new(self)
        end
        instance_variable_get "@#{name}"
      }
    end
    
    # Iterates over the object's XML subelements
    def self.each_subel
      if not self.instance_variables.index("@__subel_names")
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
      if not self.instance_variables.index("@__subel_mult_names")
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
  
    # Iterates over the object's XML atributes
    def self.each_attr    
      if not self.instance_variables.index("@__attr_names")
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
      
      @__attr_names.each {|name| yield name}
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

    # returns a string with the opening tag for the element
    def create_open_tag
      attrs = {}
      self.class.each_attr do |a|
        value = self.send(a)
        if value
          attrs[a.to_s] = value
        end
      end
      XMLUtils::create_open_tag(elname.to_s, attrs)
    end
    
    # returns a string with the closing tag for the element
    def create_close_tag
      "</"+elname.to_s+">"
    end
  
    # Declare the class as having many subelements. Instances will have a 
    # method called #subelements that will return an instance of XMLSubElements
    def self.xmlsubelements #:doc:
      define_method(:subelements) {
        if not self.instance_variables.index("@subelements")
          @subelements = XMLSubElements.new(self)
        end
        @subelements
      }
      define_method('<<') {|value|
        subelements << value
      }
      define_method(:find_first_named) {|name|
        subelements.find_first_named(name)
      }
      define_method('[]') {|name|
        subelements.find_first_named(name)
      }
      define_method(:find_all_named) {|name|
        subelements.find_all_named(name)
      }
      define_method(:has_subelements?) {true}
    end
  
    # Add a xmlattr type attribute (wrapper around attr_accessor)
    def self.xmlattr(name) #:doc:
      self.xmlattrs << name
      attr_accessor name
    end
    
    # Defines a new xml format (like XHTML or DocBook). This should be used in 
    # a class that's the super class of all the elements of a format
    def self.xmlformat(name=nil)
      class_variable_set('@@elclasses', {})
    end
    
    def self.elclasses
      class_variable_get('@@elclasses')
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
  
    # Set the element as having a value. The element will have an initializer
    # that takes a value as argument and an accessor named #value. This should
    # be used for elements that contain only text and no subelements
    def self.elwithvalue
      define_method(:hasvalue?){true}
      self.class_eval do
        def initialize(value=nil)
          @value = value
        end
      end
      attr_accessor :value
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
    
    # Have we already started the partial export of this element?
    def already_partial_exported?
      (@already_partial_exported ||= false)
    end
    
    # Have we already ended the partial export of this element?
    def already_partial_export_ended?
      (@already_partial_export_ended ||= false)
    end
    
    # Which level of indentation are we in?
    #
    # This is currently disabled until I get around to implementing proper and 
    # tested indent support.
    #def indent_level
    #  if not self.instance_variables.index '@indent_level'
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
  	  if not cl
  		  raise ElementClassNotFound, "No class defined for element type: '" + name.to_s + "'"
  		end
  		cl
    end
    
    # Gets the possible element names for a certain element.
    def self.get_element_names(name)
      get_element_class(name).get_elnames
    end
    
    # Method that checks if a given class has subelements. This is usually only
    # used when exporting stuff.
    def has_subelements?; false; end

    # tests if the element is a value element as defined by 'elwithvalue'
    def hasvalue?
      false
    end
  

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
      
      if has_subelements?
        create_xml_subelements(xmlel)
      end
      
      xmlel
    end
    
    # Import the XML into an object from a Nokogiri XML Node or Document. 
    # This call is recursive and imports any subelements found into the 
    # corresponding objects.
    def self.import_xml(xmlel)
      if xmlel.is_a? Nokogiri::XML::Document
        xmlel = xmlel.root
      end
      
      elements = []
      xmlel.children.each do |e|
        if e.text?
          elements << e.text
        else
          elclass = get_element_class(e.name)
          elements << elclass.import_xml(e)
        end
      end
      
      attributes = {}
      xmlel.attributes.each do |name, attr|
        attributes[name] = attr.value
      end
      
      new_with_content(attributes, elements)
    end
    
    # Import the XML directly from the text.
    def self.import_xml_text(text)
      parser = XMLStreamObjectParser.new(self)
      parser.parse(text)
      parser.top_element
    end
    
    # Create a new element passing it all the atributes, children and texts
    def self.new_with_content(attrs, children)
      text_children = []
      element_children = []
      
      children.each do |c|
        if c.is_a? String
          text_children << c
        else
          element_children << c
        end
      end
    
      obj = self.allocate
      obj.add_attr(attrs)
      obj.add_subel(element_children)
      obj.add_texts(text_children)
      if obj.has_subelements?
        obj.add_subelements(children)
      end
      obj
    end
    
    # add the attributes passed as a hash to the element
    def add_attr(attrs)
      attrs.each do |name, value|
        self.send("#{name}=", value)
      end
    end
    
    # add the text elements into the element
    def add_texts(texts)
      if hasvalue?
        @value = texts.join
      end
    end
    
    # add the subelements into the element
    def add_subel(children)
      children.each do |c|
        if subel_name = get_subel(c.class)
          if self.class.subel_mult? subel_name
            self.send(subel_name) <<  c
          else
            self.send(subel_name.to_s+'=', c)
          end 
        end
      end
    end
    
    # If the class is one with many subelements import all of them into the
    # object.
    def add_subelements(all_children)
      all_children.each {|c| self.subelements << c}
    end
    
    
    # create the XML text of the element
    def xml_text
      str = create_open_tag
      if self.hasvalue?
        str << XMLUtils::escape_xml(self.value)
      end
      
      each_subelement do |e|
        str << e.xml_text
      end
      
      str << create_close_tag
      str
    end
    
    # Export this element into a file. Will also start to export the parents of
    # the element. It's equivalent to calling start_partial_export followed by
    # end_partial_export.
    def partial_export(file)
      if not already_partial_exported?
        start_partial_export(file)
        end_partial_export(file)
      end
    end
    
    # Starts to export the element to a file. all the existing elements will be
    # exported. After calling this you should only add stuff that you will 
    # export explicitly by calling partial_export or start_partial_export.
    def start_partial_export(file)
      if not already_partial_exported?
        @already_partial_exported = true
        if self.__parent
          self.__parent.start_partial_export(file)
        end
        
        file << create_open_tag
        if self.hasvalue?
          file << XMLUtils::escape_xml(self.value)
        end
        
        each_subelement do |e|
          e.partial_export(file)
        end
      end
    end
    
    # Ends the partial exporting of the element. 
    def end_partial_export(file)
      if not already_partial_export_ended?
        @already_partial_export_ended = true
        
        if not already_partial_exported?
          raise "<#{self} Trying to end the export of an element that hasn't"+
                " been started yet"
        end
        
        each_subelement do |e|
          e.end_partial_export(file)
        end
        
        file << create_close_tag

        if self.__parent
          self.__parent.delete_element(self)
        end
      end
    end
  end
end
