EXECUTABLE_FILE = File.realpath(__FILE__)
$LOAD_PATH.unshift File.expand_path('../../lib', EXECUTABLE_FILE)

require 'seamless_cloning'

SeamlessCloning.clone(
  source: 'images/monster.png',
  target: 'images/wide_grass.png',
  mask_position: [50, 400],
  iterations: 5
)
