module Lucid
  class StepMatch #:nodoc:
    attr_reader :step_definition, :step_arguments

    def initialize(step_definition, name_to_match, name_to_report, step_arguments)
      raise "name_to_match can't be nil" if name_to_match.nil?
      raise "step_arguments can't be nil (but it can be an empty array)" if step_arguments.nil?
      @step_definition = step_definition
      @name_to_match = name_to_match
      @name_to_report = name_to_report
      @step_arguments = step_arguments
    end

    def args
      @step_arguments.map{|g| g.val.freeze}
    end

    def name
      @name_to_report
    end

    def invoke(multiline_arg)
      all_args = args
      all_args << multiline_arg.to_step_definition_arg if multiline_arg
      @step_definition.invoke(all_args)
    end

    def format_args(format = lambda{|a| a}, &proc)
      @name_to_report || replace_arguments(@name_to_match, @step_arguments, format, &proc)
    end

    def file_colon_line
      @step_definition.file_colon_line
    end

    def backtrace_line
      "#{file_colon_line}:in `#{@step_definition.regexp_source}'"
    end

    def text_length
      @step_definition.regexp_source.unpack('U*').length
    end

    def replace_arguments(string, step_arguments, format, &proc)
      s = string.dup
      offset = past_offset = 0
      step_arguments.each do |step_argument|
        next if step_argument.offset.nil? || step_argument.offset < past_offset

        replacement = if block_given?
          proc.call(step_argument.val)
        elsif Proc === format
          format.call(step_argument.val)
        else
          format % step_argument.val
        end

        s[step_argument.offset + offset, step_argument.val.length] = replacement
        offset += replacement.unpack('U*').length - step_argument.val.unpack('U*').length
        past_offset = step_argument.offset + step_argument.val.length
      end
      s
    end

    def inspect #:nodoc:
      sprintf("#<%s:0x%x>", self.class, self.object_id)
    end
  end

  class NoStepMatch #:nodoc:
    attr_reader :step_definition, :name

    def initialize(step, name)
      @step = step
      @name = name
    end

    def format_args(format)
      @name
    end

    def file_colon_line
      raise "No file:line for #{@step}" unless @step.file_colon_line
      @step.file_colon_line
    end

    def backtrace_line
      @step.backtrace_line
    end

    def text_length
      @step.text_length
    end

    def step_arguments
      []
    end
  end
end