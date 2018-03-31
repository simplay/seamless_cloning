module SeamlessCloning
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
end
