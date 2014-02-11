require 'gherkin/tag_expression'

module Lucid
  module AST
    class Tags
      attr_reader :tags

      def initialize(line, tags)
        @line, @tags = line, tags
      end

      def accept(visitor)
        visitor.visit_tags(self) do
          @tags.each do |tag|
            log.ast(tag)
            visitor.visit_tag_name(tag.name)
          end
        end
      end

      def accept_hook?(hook)
        Gherkin::TagExpression.new(hook.tag_expressions).evaluate(@tags)
      end

      def to_sexp
        @tags.map{|tag| [:tag, tag.name]}
      end

      private

      def log
        Lucid.logger
      end
    end
  end
end
