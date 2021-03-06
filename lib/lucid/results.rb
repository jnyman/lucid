module Lucid
  class ContextLoader

    class Results
      def initialize(context)
        @context = context
        @inserted_steps = {}
        @inserted_scenarios = {}
      end

      def configure(new_context)
        @context = Context.parse(new_context)
      end

      def step_visited(step)
        step_id = step.object_id

        unless @inserted_steps.has_key?(step_id)
          @inserted_steps[step_id] = step
          steps.push(step)
        end
      end

      def scenario_visited(scenario)
        scenario_id = scenario.object_id

        unless @inserted_scenarios.has_key?(scenario_id)
          @inserted_scenarios[scenario_id] = scenario
          scenarios.push(scenario)
        end
      end

      def steps(status = nil) #:nodoc:
        @steps ||= []
        if(status)
          @steps.select{|step| step.status == status}
        else
          @steps
        end
      end

      def scenarios(status = nil)
        @scenarios ||= []
        if(status)
          @scenarios.select{|scenario| scenario.status == status}
        else
          @scenarios
        end
      end

      def failure?
        if @context.wip?
          scenarios(:passed).any?
        else
          scenarios(:failed).any? || steps(:failed).any? ||
          (@context.strict? && (steps(:undefined).any? || steps(:pending).any?))
        end
      end
    end

  end
end
