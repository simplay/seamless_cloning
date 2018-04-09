require 'oily_png'

require "seamless_cloning/seamless_cloning"
require "seamless_cloning/gradient_field"
require "seamless_cloning/image"
require "seamless_cloning/matrix"
require "seamless_cloning/poisson_solver"
require "seamless_cloning/version"

module SeamlessCloning
  def self.root
    File.dirname __dir__
  end

  # @param source [String] path to source png image.
  #   E.g. "images/monster.png"
  # @param target [String] path to target png image.
  #   E.g. "images/wide_grass.png"
  # @param mask_position [Array<Integer>] coordinates (top, left) of mask in
  #   target image, e.g. [50, 400].
  # @param out_dir [String] path to directory where the generated files are
  #   saved to. E.g. 'out/'
  # @param iterations [Integer] maximum number of iterations used for running
  #   the poisson solver.
  def self.clone(source:,
                 target:,
                 mask_position:,
                 out_dir:,
                 iterations: PoissonSolver::MAX_ITERATIONS)

    start_x, start_y = mask_position

    img  = Image.load(source)
    out  = Image.load(target)

    mask = Matrix.ones(out.width, out.height)
    (img.width).times do |i|
      (img.height).times do |j|
        mask[start_x + i, start_y + j] = 0.0
      end
    end

    img_fit_red = Matrix.ones(out.width, out.height)
    img_fit_green = Matrix.ones(out.width, out.height)
    img_fit_blue = Matrix.ones(out.width, out.height)
    (img.width).times do |i|
      (img.height).times do |j|
        img_fit_red[start_x + i, start_y + j] = img.red[i, j]
        img_fit_green[start_x + i, start_y + j] = img.green[i, j]
        img_fit_blue[start_x + i, start_y + j] = img.blue[i, j]
      end
    end

    img_fit = Image.create_rgb(
      red: img_fit_red,
      green: img_fit_green,
      blue: img_fit_blue
    )

    vr = GradientField.new(img_fit.red)
    vg = GradientField.new(img_fit.green)
    vb = GradientField.new(img_fit.blue)

    puts "Seamless-Cloning Example"

    puts "Processing red color channel"
    result_red = PoissonSolver.new(
      start: img_fit.red,
      target: out.red,
      mask: mask,
      vectorfield: vr,
      max_iterations: iterations
    ).solve

    puts "red channel processed"

    puts "Processing green color channel"
    result_green = PoissonSolver.new(
      start: img_fit.green,
      target: out.green,
      mask: mask,
      vectorfield: vg,
      max_iterations: iterations
    ).solve

    puts "green channel processed"

    puts "Processing blue color channel"
    result_blue = PoissonSolver.new(
      start: img_fit.blue,
      target: out.blue,
      mask: mask,
      vectorfield: vb,
      max_iterations: iterations
    ).solve

    puts "blue channel processed"

    result = Image.create_rgb(
      red: result_red,
      green: result_green,
      blue: result_blue
    )

    out_filepath = File.join(root, out_dir, 'result.png')
    result.to_image(out_filepath)
    puts "Saved image `#{out_filepath}`"
  end
end

# Reload all files in this GEM excluding this file. Becomes handy when working
# with pry's edit function.
#
# @param filename [String] E.g. 'matrix.rb'
def reload(filename = nil)
  warn = $VERBOSE
  $VERBOSE = nil
  files = Dir.glob('lib/seamless_cloning/**/*.rb')
  if filename
    file = files.find do |f|
      filename == File.basename(f)
    end
    load(file)
  else
    files.each { |f| load(f) }
  end
  nil
ensure
  $VERBOSE = warn
  true
end

alias reload! reload
