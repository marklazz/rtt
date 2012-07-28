#!/usr/bin/env ruby
module Kernel
  # Suppresses warnings within a given block.
  def with_warnings_suppressed
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    yield
  ensure
    $VERBOSE = original_verbosity
  end
end
