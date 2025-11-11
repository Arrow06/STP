class CakeCutter
  def initialize(cake_string)
    @cake = cake_string.strip.split("\n").map(&:strip)
    @height = @cake.size
    @width = @cake[0].size
    @memo = {}
    build_prefix_sum
    @total_raisins = count_raisins_in_rect(0, 0, @width - 1, @height - 1)
    return if @total_raisins <= 1
    @piece_area = (@width * @height) / @total_raisins
  end

  def solve
    if @total_raisins <= 1 || (@width * @height) % @total_raisins != 0
      return format_pieces([[0, 0, @width - 1, @height - 1]]) if @total_raisins == 1
      return []
    end

    solutions = find_partitions(0, 0, @width - 1, @height - 1)
    return [] if solutions.empty?

    best_solution = solutions.max_by do |solution|
      first_piece = solution.min_by { |p| [p[1], p[0]] }
      first_piece[2] - first_piece[0] + 1
    end

    sorted_best_solution = best_solution.sort_by { |p| [p[1], p[0]] }

    format_pieces(sorted_best_solution)
  end

  private

  def build_prefix_sum
    @prefix_sum = Array.new(@height + 1) { Array.new(@width + 1, 0) }
    (0...@height).each do |y|
      (0...@width).each do |x|
        is_raisin = @cake[y][x] == 'o' ? 1 : 0
        @prefix_sum[y + 1][x + 1] = is_raisin + @prefix_sum[y][x + 1] + @prefix_sum[y + 1][x] - @prefix_sum[y][x]
      end
    end
  end

  def count_raisins_in_rect(x1, y1, x2, y2)
    return 0 if x1 > x2 || y1 > y2
    @prefix_sum[y2 + 1][x2 + 1] - @prefix_sum[y1][x2 + 1] - @prefix_sum[y2 + 1][x1] + @prefix_sum[y1][x1]
  end

  def find_partitions(x1, y1, x2, y2)
    return @memo[[x1, y1, x2, y2]] if @memo.key?([x1, y1, x2, y2])

    raisins_count = count_raisins_in_rect(x1, y1, x2, y2)
    return [] if raisins_count == 0

    rect_area = (x2 - x1 + 1) * (y2 - y1 + 1)

    if raisins_count == 1
      return rect_area == @piece_area ? [[[x1, y1, x2, y2]]] : []
    end

    if rect_area != raisins_count * @piece_area
      return []
    end

    partitions = []

    (y1...y2).each do |y_cut|
      top_raisins = count_raisins_in_rect(x1, y1, x2, y_cut)
      next if top_raisins == 0 || top_raisins == raisins_count

      top_partitions = find_partitions(x1, y1, x2, y_cut)
      next if top_partitions.empty?

      bottom_partitions = find_partitions(x1, y_cut + 1, x2, y2)
      top_partitions.each do |p1|
        bottom_partitions.each do |p2|
          partitions << (p1 + p2)
        end
      end
    end

    (x1...x2).each do |x_cut|
      left_raisins = count_raisins_in_rect(x1, y1, x_cut, y2)
      next if left_raisins == 0 || left_raisins == raisins_count

      left_partitions = find_partitions(x1, y1, x_cut, y2)
      next if left_partitions.empty?

      right_partitions = find_partitions(x_cut + 1, y1, x2, y2)
      left_partitions.each do |p1|
        right_partitions.each do |p2|
          partitions << (p1 + p2)
        end
      end
    end

    @memo[[x1, y1, x2, y2]] = partitions
  end

  def format_pieces(pieces)
    pieces.map do |x1, y1, x2, y2|
      (y1..y2).map { |y| @cake[y][x1..x2] }.join("\n")
    end
  end
end

def cut_cake(cake_string)
  CakeCutter.new(cake_string).solve
end

# Helper method to print results clearly
def print_solution(cake_name, cake_string)
  puts "--- #{cake_name} ---"
  puts "Original Cake:"
  puts cake_string
  puts

  solution = cut_cake(cake_string)
  if solution.empty?
    puts "No solution found."
  else
    puts "Cut Pieces:"
    solution.each_with_index do |piece, index|
      puts "Piece #{index + 1}:"
      puts piece
      puts
    end
  end
end

# Example usage:
cake1 = <<~CAKE
  ........
  ..o.....
  ...o....
  ........
CAKE

cake2 = <<~CAKE
  .o......
  ......o.
  ....o...
  ..o.....
CAKE

cake3 = <<~CAKE
  .o.o....
  ........
  ....o...
  ........
  .....o..
  ........
CAKE

print_solution("Cake 1", cake1)
print_solution("Cake 2", cake2)
print_solution("Cake 3", cake3)
