class TargetsList
  def initialize(grid, action)
    @grid = grid
    @action = action
  end

  EXCLUSIONS = {
    branching: [],
    change: %i[start branch branch_target confirmation],
    move: %i[branch checkanswers confirmation unconnected]
  }.freeze

  def targets; end

  def ordered_by_row
    max_rows.times.each_with_object([]) do |row, ary|
      ordered_by_column.each do |column|
        ary << column[row] if column[row].present?
      end
    end
  end

  private

  attr_reader :grid, :action

  def max_rows
    ordered_by_column.map(&:size).max
  end

  def ordered_by_column
    @ordered_by_column ||= grid.build
  end
end
