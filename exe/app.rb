require 'optparse'

EXECUTABLE_FILE = File.realpath(__FILE__)
$LOAD_PATH.unshift File.expand_path('../../lib', EXECUTABLE_FILE)

options = {}
option_parser = OptionParser.new do |opts|
  opts.on("-i", '--iterations ITER', Integer, "Number of iterations") do |iter|
    options[:iter] = iter
  end

  opts.on("-f", '--use-fast-solver', Integer, "Number of iterations") do
    ENV['SC_USE_FAST_SOLVER'] = 'true'
  end
end

option_parser.parse!

require 'seamless_cloning'

iterations = options[:iter] || 100

puts "Running #{iterations} iterations"
SeamlessCloning.clone(
  source: 'images/monster.png',
  target: 'images/wide_grass.png',
  mask_position: [50, 400],
  iterations: iterations
)
