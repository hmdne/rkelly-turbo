module RKelly
  module Visitors
    class Visitor
      TERMINAL_NODES = %w{
        Break Continue EmptyStatement False Null Number Parameter Regexp Resolve
        String This True
      }
      SINGLE_VALUE_NODES = %w{
        Parenthetical AssignExpr BitwiseNot Block Delete Element ExpressionStatement
        FunctionBody LogicalNot Return Throw TypeOf UnaryMinus UnaryPlus Void
      }
      BINARY_NODES = %w{
        Add BitAnd BitOr BitXOr CaseClause Comma Divide DoWhile Equal Greater
        GreaterOrEqual In InstanceOf LeftShift Less LessOrEqual LogicalAnd
        LogicalOr Modulus Multiply NotEqual NotStrictEqual OpAndEqual
        OpDivideEqual OpEqual OpLShiftEqual OpMinusEqual OpModEqual
        OpMultiplyEqual OpOrEqual OpPlusEqual OpRShiftEqual OpURShiftEqual
        OpXOrEqual RightShift StrictEqual Subtract Switch UnsignedRightShift
        While With
      }
      ARRAY_VALUE_NODES = %w{
        Arguments Array CaseBlock ConstStatement ObjectLiteral SourceElements
        VarStatement
      }
      NAME_VALUE_NODES = %w{
        Label Property GetterProperty SetterProperty VarDecl
      }
      PREFIX_POSTFIX_NODES  = %w{ Postfix Prefix }
      CONDITIONAL_NODES     = %w{ If Conditional }
      FUNC_CALL_NODES       = %w{ NewExpr FunctionCall }
      FUNC_DECL_NODES       = %w{ FunctionExpr FunctionDecl }
      ALL_NODES = %w{ For ForIn Try BracketAccessor DotAccessor } +
        TERMINAL_NODES + SINGLE_VALUE_NODES + BINARY_NODES + ARRAY_VALUE_NODES +
        NAME_VALUE_NODES + PREFIX_POSTFIX_NODES + CONDITIONAL_NODES +
        FUNC_CALL_NODES + FUNC_DECL_NODES

      def accept(target)
        target.accept(self)
      end

      TERMINAL_NODES.each do |type|
        define_method(:"visit_#{type}Node") { |o| o.value }
      end

      BINARY_NODES.each do |type|
        define_method(:"visit_#{type}Node") do |o|
          [o.left && o.left.accept(self), o.value && o.value.accept(self)]
        end
      end

      ARRAY_VALUE_NODES.each do |type|
        define_method(:"visit_#{type}Node") do |o|
          return nil unless o.value
          out = Array.new(length = o.value.length); i=-1
          while (i+=1) < length
            val = o.value[i]
            out[i] = val ? val.accept(self) : nil
          end
          out
          #o.value && o.value.map { |v| v ? v.accept(self) : nil }
        end
      end

      NAME_VALUE_NODES.each do |type|
        define_method(:"visit_#{type}Node") do |o|
          val = o.value
          [o.name.to_s.to_sym, val ? val.accept(self) : nil]
        end
      end

      SINGLE_VALUE_NODES.each do |type|
        define_method(:"visit_#{type}Node") do |o|
          o.value.accept(self) if o.value
        end
      end

      PREFIX_POSTFIX_NODES.each do |type|
        define_method(:"visit_#{type}Node") do |o|
          o.operand.accept(self)
        end
      end

      CONDITIONAL_NODES.each do |type|
        define_method(:"visit_#{type}Node") do |o|
          [ o.conditions.accept(self),
            o.value.accept(self),
            o.else ? o.else.accept(self) : nil
          ]
        end
      end
      FUNC_CALL_NODES.each do |type|
        define_method(:"visit_#{type}Node") do |o|
          [o.value.accept(self), o.arguments.accept(self)]
        end
      end
      FUNC_DECL_NODES.each do |type|
        define_method(:"visit_#{type}Node") do |o|
          out = Array.new(length = o.arguments.length); i = -1
          while (i += 1) < length
            out[i] = o.arguments[i].accept(self)
          end
          val = o.value
          [
            val ? val : nil,
            out, #o.arguments.map { |x| x.accept(self) },
            o.function_body.accept(self)
          ]
        end
      end

      def visit_ForNode(o)
        [
          o.init ? o.init.accept(self) : nil,
          o.test ? o.test.accept(self) : nil,
          o.counter ? o.counter.accept(self) : nil,
          o.value.accept(self)
        ]
      end

      def visit_ForInNode(o)
        [
          o.left.accept(self),
          o.right.accept(self),
          o.value.accept(self)
        ]
      end

      def visit_TryNode(o)
        [
          o.value.accept(self),
          o.catch_var ? o.catch_var : nil,
          o.catch_block ? o.catch_block.accept(self) : nil,
          o.finally_block ? o.finally_block.accept(self) : nil
        ]
      end

      def visit_BracketAccessorNode(o)
        [
          o.value.accept(self),
          o.accessor.accept(self)
        ]
      end

      def visit_DotAccessorNode(o)
        o.value.accept(self)
      end
    end
  end
end
