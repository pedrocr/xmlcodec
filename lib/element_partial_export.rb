module XMLCodec
  class XMLElement
    private
    # Have we already started the partial export of this element?
    def already_partial_exported?
      (@already_partial_exported ||= false)
    end
    
    # Have we already ended the partial export of this element?
    def already_partial_export_ended?
      (@already_partial_export_ended ||= false)
    end

    public
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
          file << XMLCodec::XMLUtils::escape_xml(self.value)
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
