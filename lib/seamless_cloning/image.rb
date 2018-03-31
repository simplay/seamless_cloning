module SeamlessCloning
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
end
