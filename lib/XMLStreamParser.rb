require "rexml/document"
require "XMLUtils"

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
    
    def array_from(start)
      @contents[start..-1]
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
    attr_reader :parent_id
    attr_reader :elstart

    def initialize(name, elstart, parser, parent_id)
      @name = name
      @parser = parser
      @elstart = elstart
      @element_id = parser.new_element_id
      @parent_id = parent_id
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

  class XMLStreamParser
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
      REXML::Document.parse_stream(text, self)
    end
    
    def tag_start(name, attrs)
      @elements << XMLSParserElement.new(name, @contents.size, 
                                              self, @elements[-1].element_id)
      @contents << XMLUtils.create_open_tag(name, attrs)
    end
    
    def text(text)
      @contents << text
    end
    
    def tag_end(name)
      @contents << "</"+name+">"
      element(name)
      @elements.pop()
    end
    
    def content
      @contents.text_from(@elements[-1].elstart)
    end
    
    def element(name)
      if @listener
        @listener.element(@elements[-1])
      end
    end
    
    def consume
      @contents.erase_from(@elements[-1].elstart)
    end
    
    # Ignore everything except tags and text for now
    def method_missing(methId, *args)
    end
  end
end
