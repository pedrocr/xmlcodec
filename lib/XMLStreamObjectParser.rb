require "rexml/document"
require "XMLUtils"

module XMLCodec
  # This class is used internally by the parser to store the information about
  # each of the elements that gets created.
  class XMLSOParserElement
    attr_reader :elclass, :consumed, :id
    
    # Create a new instance with the element name, a hash of atributes, it's
    # import/export class, the parent element and it's id
    # The id is used to fill in element_id and parent_id in XMLElement so that
    # the parser's user can know what is the tree structure between objects.
    def initialize(name, attrs, elclass, parent, id)
      @attrs = attrs
      @elclass = elclass
      @children = Hash.new([])
      @children = []
      @object = nil
      @consumed = false
      @parent = parent
      @id = id
      @name = name
    end

    # Add a child element to the object    
    def add_child(child)
      @children << child
    end
    
    # Get the actual object for the XML element, created using the elclass
    # passed to the constructor. This is cached so the object will only be 
    # created once. All subsequent calls will return the same object.
    def get_object
      if not @object
        @object = @elclass.new_with_content(@attrs, @children)
        if @parent
          @object.element_id = @id
          @object.parent_id = @parent.id
        end
      end
      @object  
    end
    
    # Consume the object so that it may be freed. The object will no longer
    # appear a a child of the parent object.
    def consume 
      @consumed = true
      @object = nil
    end
  end

  # This is a XML Stream parser that returns ruby objects for whole elements.
  # To do this a class must be defined as descending from XMLElement and having
  # set elname or elnames. To use it all you have to do is define a listener
  # that responds to methods of the form el_<element name> and define the 
  # importers for the elements as subclasses of XMLElement.
  #
  # The listener will be passed XMLSOParserElement objects. The two relevant
  # methods for it's use are XMLSOParserElement#get_object and 
  # XMLSOParserElement#consume.
  class XMLStreamObjectParser
    # Create a new parser with a listener.
    def initialize(listener=nil)
      @listener = listener
      @children = Hash.new([])
      @currel = 0
      @elements = [XMLSOParserElement.new(nil, nil, nil, nil, nil)]
      @id = 0
      @top_element = nil
    end
    
  private
    def next_id
      @id += 1
    end

    def get_elclass(name)
      XMLCodec::XMLElement.get_element_class(name)
    end
    
    def curr_element
      @elements[@currel]
    end
    
    def prev_element
      @elements[@currel - 1]
    end
    
  public
    # Parse the text with the stream parser calling the listener on any events
    # that it listens to.
    def parse(text)
      REXML::Document.parse_stream(text, self)
    end
  
    # Get the current top element of the parse. This is usually used to get the
    # root at the end of the parse.
    def top_element
      @top_element.get_object if @top_element
    end
    
    def tag_start(name, attrs) #:nodoc:
      @elements << XMLSOParserElement.new(name, attrs, get_elclass(name), 
                                          curr_element, next_id)
      @currel += 1
    end

    def text(text) #:nodoc:
      curr_element.add_child(text)
    end
    
    def tag_end(name) #:nodoc:
      obj = curr_element
      
      if @listener.respond_to?("el_"+name)
        @listener.send("el_"+name, obj)
      end
      
      if not obj.consumed
        if prev_element
          prev_element.add_child(obj.get_object)
        end
        
        @top_element = obj
      end
          
      @elements.pop
      @currel -= 1
    end
    
    # Ignore everything except tags and text for now
    def method_missing(methId, *args) #:nodoc:
    end
  end
end
