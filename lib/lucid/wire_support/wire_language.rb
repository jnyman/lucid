require 'multi_json'
require 'socket'
require 'lucid/wire_support/connection'
require 'lucid/wire_support/configuration'
require 'lucid/wire_support/wire_packet'
require 'lucid/wire_support/wire_exception'
require 'lucid/wire_support/wire_step_definition'

module Lucid
  module WireSupport

    # The wire-protocol (lanugage independent) implementation of the programming
    # language API.
    class WireLanguage
      include Interface::InterfaceMethods

      def initialize(runtime)
        @connections = []
      end

      def alias_adverbs(adverbs)
      end

      def load_code_file(wire_file)
        config = Configuration.from_file(wire_file)
        @connections << Connection.new(config)
      end

      def matcher_text(code_keyword, step_name, multiline_arg_class, matcher_type)
        matchers = @connections.map do |remote|
          remote.matcher_text(code_keyword, step_name, multiline_arg_class.to_s)
        end
        matchers.flatten.join("\n")
      end

      def step_matches(step_name, formatted_step_name)
        @connections.map{ |c| c.step_matches(step_name, formatted_step_name)}.flatten
      end

      protected

      def begin_scenario(scenario)
        @connections.each { |c| c.begin_scenario(scenario) }
        @current_scenario = scenario
      end

      def end_scenario
        scenario = @current_scenario
        @connections.each { |c| c.end_scenario(scenario) }
        @current_scenario = nil
      end
    end
  end
end