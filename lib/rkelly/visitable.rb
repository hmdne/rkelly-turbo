# frozen_string_literal: true

module RKelly
  module Visitable
    # This is a big optimization impairing readability of this code. I'm sorry for
    # that, but this path is called heavily. See git history.
    module ClassMethods
      def visitor_method_names_by_ancestors
        @visitor_method_names_by_ancestors ||= self.ancestors.reject do |i|
          %w[Kernel Object BasicObject Enumerable
             RKelly::Visitors RKelly::Visitable PP::ObjectMixin].include? i.name.to_s
        end.map do |ancestor|
          :"visit_#{ancestor.name.split('::').last}"
        end
      end
    end
    def self.included(klass)
      klass.extend(ClassMethods)
    end
    # End of the big optimization

    # Based off the visitor pattern from RubyGarden
    def accept(visitor, &block)
      klass, meth = self.class.visitor_method_names_by_ancestors.find do |meth|
        return visitor.send(meth, self, &block) if visitor.respond_to?(meth)
      end

      raise "No visitor for '#{self.class}'"
    end
  end
end
