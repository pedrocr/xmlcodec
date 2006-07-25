require 'XMLUtils'

module XMLCodec
  # A simple element that has only text inside. This is used inside 
  # XMLSubElements to be able to directly add strings to it and have them be 
  # treated as XML text elements.
  class XMLTextElement
    attr_accessor :__parent
  
    # Create a new element for the given string.
    def initialize(string)
      @value = XMLUtils::escape_xml(string)
    end
    
    # Simple to_s method that just returns the included string
    def to_s
      @value
    end
    
    # Creates the XML for the element by using add_text on the value.
    def create_xml(parent)
      parent.add_text(@value)
    end
    
    # The XML text of the element is simply it's string value.
    def xml_text
      @value
    end
    
    def end_partial_export(file)
    end
    
    def start_partial_export(file)
      file << self.xml_text
    end
    
    def partial_export(file)
      start_partial_export(file)
      end_partial_export(file)
    end
    
    def elname
      '__TEXT__'
    end
  end
  
  # This is the container class used to hold the elements for the xmlsubelements
  # and xmlsubel_mult in a XMLElement.
  class XMLSubElements
    include Enumerable
  
    # Create a new instance of the container
    def initialize(parent)
      @elements = []
      @parent = parent
    end
    
  private
    # Get the class for a given element name
    def elclass(name)
      XMLElement.get_element_class(name)
    end
  
  public
    # Returns the first element in the collection with the given element name
    def find_first_named(name)
      self.find {|el| el.elname.to_s == name.to_s}
    end
    
    # Returns the elements in the collection with the given element name
    def find_all_named(name)
      self.find_all {|el| el.elname.to_s == name.to_s}
    end
  
    # Adds a value to the collection. The value may be either a String or a 
    # descendant of XMLElement. If it's a string it's converted into a 
    # XMLTextElement
    def <<(value)
      if value.instance_of? String
        value = XMLTextElement.new(value)
      end
      value.__parent = @parent
      @elements << value
    end
    
    # Get the element with the given number
    def [](num)
      @elements[num]
    end
    
    # Get the number of elements in the container
    def size
      @elements.size
    end
    
    # Create the XML of all the elements by creating the XML for each of them.
    def create_xml(parent)
      @elements.each{|e| e.create_xml(parent)}
    end
    
    # Import the XML of all the elements
    def import_xml(xmlelements)
      xmlelements.each do |xmlel|
        if xmlel.kind_of? REXML::Text
          self << xmlel.to_s
        else
          self << elclass(xmlel.name.to_sym).import_xml(xmlel)
        end
      end
    end
    
    # Iterate all the values in the collection
    def each
      @elements.dup.each {|e| yield e}
    end
    
    # Delete a certain element from the collection
    def delete_element(element)
      @elements.delete(element)
    end
  end
end
