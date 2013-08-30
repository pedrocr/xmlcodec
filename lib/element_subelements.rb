module XMLCodec
  class XMLElement
    public
    # Method that checks if a given class has subelements. This is usually only
    # used when exporting stuff.
    def self.has_subelements?; false end
    def has_subelements?; self.class.has_subelements? end

    private
    # Declare the class as having many subelements. Instances will have a 
    # method called #subelements that will return an instance of XMLSubElements
    def self.xmlsubelements #:doc:
      define_method(:subelements) {
        @subelements ||= XMLSubElements.new(self)
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
      self.class_eval do
        def self.has_subelements?; true; end
      end
    end
  end
end
