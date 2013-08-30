module XMLCodec
  class XMLElement
    public  
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
        if not self.class.attr_names.include?(name.to_sym)
          if self.class.class_variable_get(:@@strict_parsing)
            raise ElementAttributeNotFound, "No attribute '#{name}' defined for class '#{self.class}'" 
          end
        else
          self.send("#{name}=", value)
        end
      end
    end
    
    # add the text elements into the element
    def add_texts(texts)
      if self.hasvalue?
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
  end
end
