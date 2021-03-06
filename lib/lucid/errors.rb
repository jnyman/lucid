module Lucid
  # Raised when there is no matching test definition for a step.
  class Undefined < StandardError
    attr_reader :step_name

    def initialize(step_name)
      super %{Undefined step: "#{step_name}"}
      @step_name = step_name
    end

    def nested!
      @nested = true
    end

    def nested?
      @nested
    end
  end

  # Raised when a test definition block invokes Domain#pending.
  class Pending < StandardError
  end

  # Raised when a step matches two or more test definitions.
  class Ambiguous < StandardError
    def initialize(step_name, step_definitions, used_guess)
      message = "Ambiguous match of \"#{step_name}\":\n\n"
      message << step_definitions.map{|sd| sd.backtrace_line}.join("\n")
      message << "\n\n"
      message << "You can run again with --guess to make Lucid be a little more smart about it.\n" unless used_guess
      super(message)
    end
  end

  class TagExcess < StandardError
    def initialize(messages)
      super(messages.join("\n"))
    end
  end
end
