require 'rexml/document'
require 'stringio'

# This module holds generic XML utilities. The module's methods are simple 
# XML utilities. The module also contains XMLStreamParser, a Generic XML Stream 
# parser whose events are the text of whole elements instead of start and end 
# tags.

module XMLUtils
  # Gets the REXML DOM for a given filename that must be a XML file.
  def self.getdoc(filename)
    file = File.new(filename, 'r')
    REXML::Document.new file
  end

  # Count the number of elements that correspond to a given xpath in a file.
  def self.count_elements(path, filename)
    doc = getdoc(filename)
    i = 0
    REXML::XPath.each(doc, path) {|element| i+=1}
    return i
  end

  # Test if a given xpath exists in the file.
  def self.element_exists(path, filename)
    count_elements(path,filename)>0
  end

  # Get a xpath from a REXML document.
  def self.select_path_doc(path, doc)
    element = REXML::XPath.first(doc, path)
    return "" if not element
    if element.respond_to?("value")
      return element.value || ""
    end
    return element.text || ""
  end

  # Get a xpath from a file.
  def self.select_path(path, filename)
    XMLUtils::select_path_doc(path, getdoc(filename))
  end
  
  # Create an open tag.
  def self.create_open_tag(name, attrs)
    str = "<"+name
    attrs.each {|name, value| str << " #{name}='#{value}'"}
    str << ">"
    str
  end
  
  # Escape a string so that it can be included in a XML document
  def self.escape_xml(string)
    t = REXML::Text.new('')
    str = ''
    t.write_with_substitution(str, string)
    str
  end
  
  # Gets the xpath inside a given document that can either be a string or a 
  # REXML::Document
  #
  # opts can have:
  #   :multiple: fetch all the occurences of the xpath
  #   :with_attrs: include the attribute contents in the result
  #   :recursive: recursively include all the subelements of the matches
  def self.get_xpath(path, doc, opts={})
    if doc.is_a? REXML::Document
      doc = doc
    else
      doc = REXML::Document.new(doc)
    end
    
    if opts[:multiple]
      strs = []
      REXML::XPath.each(doc.root, path) do |e|
        t = get_rexml_content(e, opts)
        strs << t if t != ''
      end
      return strs.join(' ')
    else
      return get_rexml_content(REXML::XPath.first(doc, path), opts)
    end
  end
  
  def self.get_rexml_content(element, opts={})
    return '' if not element
    strs = []
    if element.respond_to?('value')
      return element.value || ''
    else
      if opts[:with_attrs]
        element.attributes.each {|name, value| strs << value if value != ''}
      end
      if not opts[:recursive]
        element.texts.each {|t| strs << t if t != ''}
      else  
        element.to_a.each do |e|
          t = get_rexml_content(e, opts)
          strs << t if t != ''
        end
      end
    end
    strs.join(' ')
  end
end
