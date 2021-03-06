require "rexml/document"

module XMLCodec
  # This class is used internally by the parser to store the information about
  # each of the elements that gets created.
  class XMLSOParserElement
    attr_reader :elclass, :consumed, :id, :depth, :parent, :name
    
    # Create a new instance with the element name, a hash of atributes, it's
    # import/export class, the parent element and it's id
    # The id is used to fill in element_id and parent_id in XMLElement so that
    # the parser's user can know what is the tree structure between objects.
    def initialize(name, attrs, elclass, parent, id, depth)
      @attrs = attrs
      @elclass = elclass
      @children = Hash.new([])
      @children = []
      @object = nil
      @consumed = false
      @parent = parent
      @id = id
      @name = name
      @depth = depth
    end

    # Add a child element to the object    
    def add_child(child)
      @children << child
    end
    
    # Get the actual object for the XML element, created using the elclass
    # passed to the constructor. This is cached so the object will only be 
    # created once. All subsequent calls will return the same object.
    def get_object
      return nil if not @elclass
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
  class XMLStreamObjectParser < Nokogiri::XML::SAX::Document
    # Create a new parser with a listener.
    def initialize(base_element, listener=nil)
      @base_element = base_element
      @listener = listener
      @children = Hash.new([])
      @currel = 0
      @elements = [XMLSOParserElement.new(nil, nil, nil, nil, nil, 0)]
      @id = 0
      @top_element = nil
      @allvalue = 0
    end
    
  private
    def next_id
      @id += 1
    end

    def get_elclass(name)
      @base_element.get_element_class(name)
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
      parser = Nokogiri::XML::SAX::Parser.new(self)
      parser.parse(text)
    end
  
    # Get the current top element of the parse. This is usually used to get the
    # root at the end of the parse.
    def top_element
      @top_element.get_object if @top_element
    end
    
    def start_element(name, attrs) #:nodoc:
      elclass =  get_elclass(name)
      if @allvalue > 0
        curr_element.get_object.value << XMLUtils.create_open_tag(name,attrs)
        @allvalue += 1
      else
        @elements << XMLSOParserElement.new(name, attrs, elclass, 
                                            curr_element, next_id, 
                                            curr_element.depth+1)
        @currel += 1
        @allvalue = 1 if elclass && elclass.allvalue?
      end
    end

    def characters(text) #:nodoc:
      if @allvalue > 0
        curr_element.get_object.value << text
      else
        curr_element.add_child(text)
      end
    end
    
    def end_element(name) #:nodoc:
      elclass =  get_elclass(name)
      if @allvalue > 1
        # We're closing an allvalue subelement, just output it and pop
        curr_element.get_object.value << XMLUtils.create_close_tag(name) 
        @allvalue -= 1  
      else
        obj = curr_element
        
        if @listener.respond_to?("el_"+name)
          @listener.send("el_"+name, obj)
        end
        
        if not obj.consumed
          real_obj = obj.get_object

          if prev_element && real_obj
            prev_element.add_child(real_obj)
          end
          
          @top_element = obj
        end
            
        @elements.pop
        @currel -= 1
        @allvalue = 0
      end
    end
  end
end
