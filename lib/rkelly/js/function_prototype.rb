module RKelly
  module JS
    # This is the object protytpe
    # ECMA-262 15.2.4
    class FunctionPrototype < ObjectPrototype
      def initialize(function)
        super()
        @class_name = 'Object'
        self['constructor'] = VALUE[function]
        self['arguments'].value = nil
      end
    end
  end
end
