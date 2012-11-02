# I fucking hate that "Finished catalog..." notice that gets printed
# on a run that does nothing else. `time` exists if we need to time
# something, and I don't want any output if nothing happened. This
# filters out the appropriate benchmark call.

module Puppet::Util
  alias_method :benchmark_without_filtering, :benchmark

  def benchmark(*args, &block)
    _, msg = args

    return yield if /finished catalog/i =~ msg
    benchmark_without_filtering(*args, &block)
  end
end
