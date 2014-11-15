module LoadsConstant
  def loads_constant(name, options)
    before do
      Loader.new(name, options.fetch(:from), self).load
    end
  end

  class Loader
    def initialize(name, source_location, example)
      @name, @source_location, @example = name, source_location, example
    end

    def load
      return if autoloading_possible?
      stub_nesting
      load_source
    end

    def stub_nesting
      full_nesting_constant_names.each do |constant_name|
        next if constant_name == @name # don't stub innermost constant
        @example.stub_const constant_name, Module.new
      end
    end

    def load_source
      # We need to use Kernel.load instead of require, because require
      # only loads once.
      # After the current example is finished, RSpec restores the original
      # constants we stubbed, making the loaded constant unavailable for
      # the next example. The code defining it needs to be run again, and
      # require would not allow that.
      source_path = relative_rails_root +
        @source_location + '/' +
        underscored_demodulized_name + '.rb'
      Kernel.load source_path
      # @TODO assert constant now exists
    end

    def relative_rails_root
      File.dirname(__FILE__) + '/../../'
    end

    def autoloading_possible?
      # When this is called, all spec files have already been loaded, to if Rails
      # has not been loaded at this point, it never will.
      defined?(::Rails)
    end

    def demodulized_name
      # Don't depend upon AS here
      @name.split('::').last
    end

    def underscored_demodulized_name
      # Don't depend upon AS here
      demodulized_name.each_char.slice_before(/[A-Z]/).map do |slice|
        [
          slice.first.downcase, *slice.drop(1)
        ].join('')
      end.join('_')
    end

    def full_nesting_constant_names # ordered from outermost to innermost
      nesting_constant_names.each_with_object([]) do |name, result|
        full_name = [result.last, name].compact.join('::')
        result.push full_name
      end
    end

    def nesting_constant_names # ordered from outermost to innermost
      @name.split('::')
    end
  end
end

