module SeamlessCloning
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
end
