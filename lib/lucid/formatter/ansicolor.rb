require 'lucid/platform'
require 'lucid/ansicolor'

if Lucid::IRONRUBY
  begin
    require 'iron-term-ansicolor'
  rescue LoadError
    STDERR.puts %{*** WARNING: You must "gem install iron-term-ansicolor" to get colored ouput with IronRuby}
  end
end

if Lucid::WINDOWS_MRI
  unless ENV['ANSICON']
    STDERR.puts %{*** WARNING: You must use ANSICON (https://github.com/adoxa/ansicon/) to get colored output on Windows}
    Lucid::Term::ANSIColor.coloring = false
  end
end

Lucid::Term::ANSIColor.coloring = false if !STDOUT.tty? && !ENV.has_key?('AUTOTEST')

module Lucid
  module Formatter
    # Defines aliases for colored output. You don't invoke any methods from this
    # module directly, but you can change the output colors by defining
    # a <tt>LUCID_COLORS</tt> variable in your shell, very much like how you can
    # tweak the familiar POSIX command <tt>ls</tt> with $LS_COLORS.
    #
    # The colors that you can change are:
    #
    # * <tt>undefined</tt>     - defaults to <tt>yellow</tt>
    # * <tt>pending</tt>       - defaults to <tt>yellow</tt>
    # * <tt>pending_param</tt> - defaults to <tt>yellow,bold</tt>
    # * <tt>failed</tt>        - defaults to <tt>red</tt>
    # * <tt>failed_param</tt>  - defaults to <tt>red,bold</tt>
    # * <tt>passed</tt>        - defaults to <tt>green</tt>
    # * <tt>passed_param</tt>  - defaults to <tt>green,bold</tt>
    # * <tt>outline</tt>       - defaults to <tt>cyan</tt>
    # * <tt>outline_param</tt> - defaults to <tt>cyan,bold</tt>
    # * <tt>skipped</tt>       - defaults to <tt>cyan</tt>
    # * <tt>skipped_param</tt> - defaults to <tt>cyan,bold</tt>
    # * <tt>comment</tt>       - defaults to <tt>grey</tt>
    # * <tt>tag</tt>           - defaults to <tt>cyan</tt>
    #
    # For instance, if your shell has a black background and a green font (like the
    # "Homebrew" settings for OS X' Terminal.app), you may want to override passed
    # steps to be white instead of green.
    #
    # Although not listed, you can also use <tt>grey</tt>.
    #
    # Examples: (On Windows, use SET instead of export.)
    #
    #   export LUCID_COLORS="passed=white"
    #   export LUCID_COLORS="passed=white,bold:passed_param=white,bold,underline"
    #
    # To see what colors and effects are available, just run this in your shell:
    #
    #   ruby -e "require 'rubygems'; require 'term/ansicolor'; puts Lucid::Term::ANSIColor.attributes"
    #
    module ANSIColor
      include Lucid::Term::ANSIColor

      ALIASES = Hash.new do |h,k|
        if k.to_s =~ /(.*)_param/
          h[$1] + ',bold'
        end
      end.merge({
        'undefined' => 'yellow',
        'pending'   => 'yellow',
        'failed'    => 'red',
        'passed'    => 'green',
        'outline'   => 'cyan',
        'skipped'   => 'cyan',
        'comment'   => 'grey',
        'tag'       => 'cyan'
      })

      # Example: export LUCID_COLORS="passed=red:failed=yellow"
      if ENV['LUCID_COLORS']
        ENV['LUCID_COLORS'].split(':').each do |pair|
          a = pair.split('=')
          ALIASES[a[0]] = a[1]
        end
      end

      # Eval to define the color-named methods required by Term::ANSIColor.
      #
      # Examples:
      #
      #   def failed(string=nil, &proc)
      #     red(string, &proc)
      #   end
      #
      #   def failed_param(string=nil, &proc)
      #     red(bold(string, &proc)) + red
      #   end
      ALIASES.each_key do |method_name|
        unless method_name =~ /.*_param/
          code = <<-EOF
          def #{method_name}(string=nil, &proc)
            #{ALIASES[method_name].split(',').join('(') + '(string, &proc' + ')' * ALIASES[method_name].split(',').length}
          end
          # This resets the colour to the non-param colour
          def #{method_name}_param(string=nil, &proc)
            #{ALIASES[method_name+'_param'].split(',').join('(') + '(string, &proc' + ')' * ALIASES[method_name+'_param'].split(',').length} + #{ALIASES[method_name].split(',').join(' + ')}
          end
          EOF
          eval(code)
        end
      end

      def self.define_grey #:nodoc:
        begin
          gem 'genki-ruby-terminfo'
          require 'terminfo'
          case TermInfo.default_object.tigetnum('colors')
          when 0
            raise "Your terminal doesn't support colors."
          when 1
            ::Lucid::Term::ANSIColor.coloring = false
            alias grey white
          when 2..8
            alias grey white
          else
            define_real_grey
          end
        rescue Exception => e
          if e.class.name == 'TermInfo::TermInfoError'
            STDERR.puts '*** WARNING ***'
            STDERR.puts "You have the genki-ruby-terminfo gem installed, but you haven't set your TERM variable."
            STDERR.puts 'Try setting it to TERM=xterm-256color to get color in output.'
            STDERR.puts "\n"
            alias grey white
          else
            define_real_grey
          end
        end
      end

      def self.define_real_grey
        def grey(string)
          if ::Lucid::Term::ANSIColor.coloring?
            "\e[90m#{string}\e[0m"
          else
            string
          end
        end
      end

      define_grey

      def lucid(n)
        ('(::) ' * n).strip
      end

      def green_lucid(n)
        blink(green(lucid(n)))
      end

      def red_lucid(n)
        blink(red(lucid(n)))
      end

      def yellow_lucid(n)
        blink(yellow(lucid(n)))
      end
    end
  end
end
