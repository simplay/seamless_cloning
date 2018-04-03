require 'benchmark'

EXECUTABLE_FILE = File.realpath(__FILE__)
$LOAD_PATH.unshift File.expand_path('../../lib', EXECUTABLE_FILE)

require_relative '../lib/seamless_cloning'

Benchmark.bm do |x|
  x.report('c-ext:') do
    SeamlessCloning.clone(
      source: 'images/monster.png',
      target: 'images/wide_grass.png',
      mask_position: [50, 400],
      iterations: 200
    )
  end
  x.report('ruby:') do
    ENV['SC_USE_RUBY_SOLVER'] = 'true'
    SeamlessCloning.clone(
      source: 'images/monster.png',
      target: 'images/wide_grass.png',
      mask_position: [50, 400],
      iterations: 200
    )
  end
end
