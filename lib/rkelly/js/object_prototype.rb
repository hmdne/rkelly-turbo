module RKelly
  module JS
    # This is the object protytpe
    # ECMA-262 15.2.4
    class ObjectPrototype < Base
      def initialize
        super
        self['toString'].function = unbound_method(:toString) do
          "[object #{@class_name}]"
        end
      end
    end
  end
end
