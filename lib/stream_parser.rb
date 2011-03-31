require "rexml/document"

module XMLUtils
  class XMLSParserContents
    def initialize
      @contents = []
    end
    
    def add(content)
      @contents << content
    end
    
    def <<(content)
      add(content)
    end
    
    def text_from(start)
      @contents[start..-1].join
    end
    
    def size
      @contents.size
    end
    
    def erase_from(start)
      @contents = @contents[0..(start-1)]
    end
  end

  class XMLSParserElement
    attr_reader :name
    attr_reader :element_id
    attr_reader :parent_id, :parent
    attr_reader :elstart

    def initialize(name, elstart, parser, parent)
      @name = name
      @parser = parser
      @elstart = elstart
      @element_id = parser.new_element_id
      @parent = parent
      @parent_id = parent.element_id if parent
    end
    
    def self.root(parser)
      self.new("__XML_ROOT__", 0, parser, nil)
    end
    
    def content
      @parser.contents.text_from(@elstart)
    end
    
    def consume
      @parser.consume
    end
  end

  class XMLStreamParser < Nokogiri::XML::SAX::Document
    attr_reader :contents
    
    def initialize(listener=nil)
      @listener = listener
      @contents = XMLSParserContents.new
      @elid = 0
      @elements = [XMLSParserElement.root(self)]
    end

    def new_element_id
      previous = @elid
      @elid += 1
      previous
    end

    def parse(text)
      parser = Nokogiri::XML::SAX::Parser.new(self)
      parser.parse(text)
    end
    
    def start_element(name, attrs)
      @elements << XMLSParserElement.new(name, @contents.size, 
                                              self, @elements[-1])
      @contents << XMLCodec::XMLUtils.create_open_tag(name, attrs)
    end
    
    def characters(text)
      @contents << XMLCodec::XMLUtils.escape_xml(text)
    end
    
    def end_element(name)
      @contents << "</"+name+">"
      if @listener.respond_to? 'el_'+name
        @listener.send('el_'+name, @elements[-1])
      end
      @elements.pop()
    end
    
    def content
      @contents.text_from(@elements[-1].elstart)
    end
    
    def consume
      @contents.erase_from(@elements[-1].elstart)
    end
  end
end
