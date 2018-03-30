# Based on the ideas and concept in this paper:
# http://www.cad.zju.edu.cn/home/zldong/course/possion/possion2003.pdf

# require 'chunky_png'
require 'oily_png'

class Image
  attr_reader :width,
              :height,
              :red,
              :green,
              :blue

  # @param red [Matrix] red color channel
  # @param green [Matrix] green color channel
  # @param blue [Matrix] blue color channel
  def initialize(red:, green:, blue:)
    @width = red.width
    @height = red.height

    @red = red
    @green = green
    @blue = blue
  end


  def self.load(filepath)
    # all pixels are encoded from left to right, top to bottom, using 1 byte
    # per channel
    image = ChunkyPNG::Image.from_file(filepath)

    pixels = image.pixels
    width = image.width
    height = image.height

    # red
    # mask[2,2] >> 24

    red_pixels = []
    blue_pixels = []
    green_pixels = []

    # ignore alpha channel and transform to range [0.0, 1.0]
    pixels.each do |p|
      red_pixels   << ((p & 0xff000000) >> 24) / 255.0
      green_pixels << ((p & 0x00ff0000) >> 16) / 255.0
      blue_pixels  << ((p & 0x0000ff00) >> 8) / 255.0
    end

    red = Matrix.new(red_pixels, width, height)
    green = Matrix.new(green_pixels, width, height)
    blue = Matrix.new(blue_pixels, width, height)

    Image.new(
      red: red,
      green: green,
      blue: blue
    )
  end

  def self.create_rgb(red:, green:, blue:)
    Image.new(
      red: red,
      green: green,
      blue: blue
    )
  end

  # saves a png iamge without alpha channel information
  def to_image(filename = 'filename.png')
    png = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)
    height.times do |j|
      width.times do |i|
        png[i, j] = ChunkyPNG::Color.rgb(
          (red[i, j] * 255).to_i,
          (green[i, j] * 255).to_i,
          (blue[i, j] * 255).to_i
        )
      end
    end
    png.save(filename, :interlace => true)
  end
end

# all pixels are encoded from left to right, top to bottom, using 1 byte
# per channel
class Matrix
  attr_reader :data, :width, :height

  def initialize(data, width, height)
    @data = data
    @width = width
    @height = height
  end

  def self.zeros(width, height)
    data = (1..width * height).map { 0.0 }
    Matrix.new(data, width, height)
  end

  def self.ones(width, height)
    data = (1..width * height).map { 1.0 }
    Matrix.new(data, width, height)
  end

  # Example
  #   matrix[30, 3] #=> 3
  # @param [Integer] x The x-coordinate of the pixel (column)
  # @param [Integer] y The y-coordinate of the pixel (row)
  def [](x, y)
    @data[y * @width + x]
  end

  # Example
  #   matrix[30, 3] = 3.0
  #
  # @param [Integer] x The x-coordinate of the pixel (column)
  # @param [Integer] y The y-coordinate of the pixel (row)
  def []=(x, y, value)
    @data[y * @width + x] = value
  end

  def sum
    @data.sum
  end

  # saves a png iamge without alpha channel information
  def to_image(filename = 'filename.png')
    png = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)
    height.times do |j|
      width.times do |i|
        png[i, j] = ChunkyPNG::Color.rgb(
          (self[i, j] * 255).to_i, 0, 0
        )
      end
    end
    png.save(filename, :interlace => true)
  end
end

class GradientField
  attr_reader :dx, :dy, :width, :height

  # @param matrix [Array<Array<Float>>]
  def initialize(matrix)
    @matrix = matrix
    @width = matrix.width
    @height = matrix.height

    dx = []
    dy = []

    @dx = Matrix.zeros(matrix.width, matrix.height)
    @dy = Matrix.zeros(matrix.width, matrix.height)

    @matrix.width.times do |i|
      @matrix.height.times do |j|
        if j + 1 < @matrix.height
          @dx[i, j] = (@matrix[i, j + 1] - @matrix[i, j])
        end

        if i + 1 < @matrix.width
          @dy[i, j] = (@matrix[i + 1, j] - @matrix[i, j])
        end
      end
    end
  end

  # saves a png iamge without alpha channel information
  def to_image(filename = 'filename.png')
    png = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)
    height.times do |j|
      width.times do |i|
        png[i, j] = ChunkyPNG::Color.rgb(
          (dx[i, j] * 255).to_i,
          (dy[i, j] * 255).to_i,
          0
        )
      end
    end
    png.save(filename, :interlace => true)
  end

end

class PossionSolver
  MAX_ITERATIONS = 10_000
  THRESHOLD = 1E-12

  attr_reader :start, :target, :mask, :vectorfield

  def initialize(start:,
                 target:,
                 mask:,
                 vectorfield:,
                 max_iterations: MAX_ITERATIONS)

    @start          = start
    @target         = target
    @mask           = mask
    @vectorfield    = vectorfield
    @max_iterations = max_iterations
  end

  def solve
    vx = vectorfield.dx
    vy = vectorfield.dy

    MAX_ITERATIONS.times do |iter|
      previous_out = target

      start.width.times do |w|
        start.height.times do |h|

          # only visit masked region
          next unless mask[w, h].zero?

          left   = previous_out[w - 1, h]
          right  = previous_out[w + 1, h]
          top    = previous_out[w    , h + 1]
          bottom = previous_out[w    , h - 1]

          # image neighborhood contribution
          img_neighbors = left + right + top + bottom

          # partial derivatives of vectorfields
          dvx = vx[w - 1, h] - vx[w, h]
          dvy = vy[w, h - 1] - vy[w, h]

          # total derivative
          dv = (dvx + dvy)

          v = (img_neighbors + dv) / 4.0
          target[w, h] = v
        end
      end

      puts "Iteration #{iter} / #{MAX_ITERATIONS}" if iter % 10 == 0

      # error = (target.sum - previous_out.sum).abs
      # break if error < THRESHOLD
    end

    target
  end
end

start_x = 50; start_y = 400

img  = Image.load("images/monster.png")
out  = Image.load("images/wide_grass.png")

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
result_red = PossionSolver.new(
  start: img_fit.red,
  target: out.red,
  mask: mask,
  vectorfield: vr
).solve

puts "red channel processed"

puts "Processing green color channel"
result_green = PossionSolver.new(
  start: img_fit.green,
  target: out.green,
  mask: mask,
  vectorfield: vg
).solve

puts "green channel processed"

puts "Processing blue color channel"
result_blue = PossionSolver.new(
  start: img_fit.blue,
  target: out.blue,
  mask: mask,
  vectorfield: vb
).solve

puts "blue channel processed"

result = Image.create_rgb(
  red: result_red,
  green: result_green,
  blue: result_blue
)

result.to_image('result.png')
puts "Saved image `result.png`"
