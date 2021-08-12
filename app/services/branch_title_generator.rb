module BranchTitleGenerator
  def title
    possible_title = branches.size + 1
    name = I18n.t(
      '.default_values.branching_title',
      branching_number: possible_title
    )

    loop do
      break unless name.in?(titles)

      possible_title += 1
      name = I18n.t(
        '.default_values.branching_title',
        branching_number: possible_title
      )
    end

    name
  end

  def titles
    @titles ||= branches.map(&:title)
  end
end
