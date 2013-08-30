module XMLCodec
  class XMLElement
    public
    # tests if the element is a value element as defined by 'elwithvalue'
    def self.hasvalue?; false end
    def hasvalue?; self.class.hasvalue? end

    # tests if the element is a value element as defined by 'elallvalue'
    def self.allvalue?; false end
    def allvalue?; self.class.allvalue?; end

    private
    # Set the element as having a value. The element will have an initializer
    # that takes a value as argument and an accessor named #value. This should
    # be used for elements that contain only text and no subelements
    def self.elwithvalue
      self.class_eval do
        def self.hasvalue?; true; end
      end
      self.class_eval do
        def initialize(value=nil)
          @value = value
        end
      end
      attr_accessor :value
    end

    # Set the element as having a value that eats up any subelements as if they
    # were text. The element will behave similarly to "elwithvalue" with an 
    # initializar that takes a value as argument and an accessor named #value
    # and will consume all its subelements as if they were text. This should
    # be used for elements that contain subelements that you want to treat as
    # text like <content> in Atom
    def self.elallvalue
      self.elwithvalue
      self.class_eval do
        def self.allvalue?; true; end
      end
    end
  end
end
