require 'rexml/document'
require 'stringio'

# This module holds generic XML utilities. The module's methods are simple 
# XML utilities. The module also contains XMLStreamParser, a Generic XML Stream 
# parser whose events are the text of whole elements instead of start and end 
# tags.

module XMLCodec
  module XMLUtils
    # Gets the Nokogiri DOM for a given filename that must be a XML file.
    def self.getdoc(filename)
      Nokogiri::XML::Document.parse File.new(filename, 'r')
    end

    # Count the number of elements that correspond to a given xpath in a file.
    def self.count_elements(path, filename)
      getdoc(filename).xpath(path).size
    end

    # Test if a given xpath exists in the file.
    def self.element_exists(path, filename)
      count_elements(path,filename)>0
    end

    # Get a xpath from a Nokogiri::XML::Document.
    def self.select_path_doc(path, doc)
      els = doc.xpath(path)
      return "" if !els[0]
      els[0].children.to_s
    end

    # Get a xpath from a file.
    def self.select_path(path, filename)
      select_path_doc(path, getdoc(filename))
    end
    
    # Create an open tag.
    def self.create_open_tag(name, attrs)
      str = "<"+name
      attrs.each {|name, value| str << " #{name}='#{value}'"}
      str << ">"
      str
    end

    # Create a close tag.
    def self.create_close_tag(name)
      "</"+name.to_s+">"
    end
    
    # Escape a string so that it can be included in a XML document
    def self.escape_xml(string)
      Nokogiri::XML::Text.new(string, Nokogiri::XML::Document.new).to_s
    end
  end
end
