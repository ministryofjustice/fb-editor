class PageDisconnectionWarning
  def initialize(current_grid:, potential_grid:)
    @current_grid = current_grid
    @potential_grid = potential_grid
  end

  def show_warning?
    return if potential_pages_in_main_flow?

    return if current_missing? || current_detached?

    (current_present? && potential_missing?) ||
      (current_present? && potential_detached?)
  end

  private

  attr_reader :current_grid, :potential_grid

  def potential_present?
    !potential_checkanswers_verifier.missing? &&
      !potential_confirmation_verifier.missing?
  end

  def potential_pages_in_main_flow?
    (
      !potential_checkanswers_verifier.missing? &&
        !potential_checkanswers_verifier.detached?
    ) &&
      (
        !potential_confirmation_verifier.missing? &&
          !potential_confirmation_verifier.detached?
      )
  end

  def current_present?
    !current_checkanswers_verifier.missing? &&
      !current_confirmation_verifier.missing?
  end

  def current_missing?
    current_checkanswers_verifier.missing? ||
      current_confirmation_verifier.missing?
  end

  def current_detached?
    current_checkanswers_verifier.detached? ||
      current_confirmation_verifier.detached?
  end

  def potential_missing?
    potential_checkanswers_verifier.missing? ||
      potential_confirmation_verifier.missing?
  end

  def potential_detached?
    potential_checkanswers_verifier.detached? ||
      potential_confirmation_verifier.detached?
  end

  def current_checkanswers_verifier
    MetadataPresenter::PageWarning.new(
      page: current_grid.service.checkanswers_page,
      main_flow_uuids: current_grid.flow_uuids
    )
  end

  def current_confirmation_verifier
    MetadataPresenter::PageWarning.new(
      page: current_grid.service.confirmation_page,
      main_flow_uuids: current_grid.flow_uuids
    )
  end

  def potential_checkanswers_verifier
    MetadataPresenter::PageWarning.new(
      page: potential_grid.service.checkanswers_page,
      main_flow_uuids: potential_grid.flow_uuids
    )
  end

  def potential_confirmation_verifier
    MetadataPresenter::PageWarning.new(
      page: potential_grid.service.confirmation_page,
      main_flow_uuids: potential_grid.flow_uuids
    )
  end
end
