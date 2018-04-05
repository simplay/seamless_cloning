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
      if ENV['SC_USE_RUBY_SOLVER']
        solve_slow
      else
        solve_fast
      end
    end

    def clamp(data)
      data.map do |e|
        if e < 0.0
          0.0
        elsif e > 1.0
          1.0
        else
          e
        end
      end
    end

    def solve_fast
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
      r = clamp(r)

      Matrix.new(r, start.width, start.height)
    end

    def solve_slow
      vx = vectorfield.dx
      vy = vectorfield.dy

      max_iterations.times do |iter|
        previous_out = target

        start.width.times do |w|
          start.height.times do |h|

            # only visit masked region
            next unless mask[w, h].zero?

            left   = previous_out[w,     h - 1]
            right  = previous_out[w,     h + 1]
            top    = previous_out[w + 1, h]
            bottom = previous_out[w - 1, h]

            # image neighborhood contribution
            img_neighbors = left + right + top + bottom

            # partial derivatives of vectorfields
            dvx = vx[w,     h - 1] - vx[w, h]
            dvy = vy[w - 1, h - 1] - vy[w, h]

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

      r = clamp(target.data)
      Matrix.new(r, start.width, start.height)
    end
  end
end
