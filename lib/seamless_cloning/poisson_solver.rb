module SeamlessCloning
  class PossionSolver
    MAX_ITERATIONS = 10_000
    THRESHOLD = 1E-12

    attr_reader :start,
                :target,
                :mask,
                :vectorfield,
                :max_iterations

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

      r = FastPoissonSolver.solve(
        target.width,
        target.height,
        max_iterations,
        target.data,
        mask.data,
        vx.data,
        vy.data
      )
      Matrix.new(r, start.width, start.height)
    end

    def solve_o
      vx = vectorfield.dx
      vy = vectorfield.dy

      max_iterations.times do |iter|
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

        puts "Iteration #{iter} / #{max_iterations}" if iter % 200 == 0

        # error = (target.sum - previous_out.sum).abs
        # break if error < THRESHOLD
      end

      target
    end
  end
end
