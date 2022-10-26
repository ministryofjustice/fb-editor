class UndoPresenter
  UNDO_REDO_TEXT = {
    'undo' => {
      'change_next_page' => I18n.t('actions.undo_redo.undo_change_next_page'),
      'move' => I18n.t('actions.undo_redo.undo_move')
    },
    'redo' => {
      'change_next_page' => I18n.t('actions.undo_redo.redo_change_next_page'),
      'move' => I18n.t('actions.undo_redo.redo_move')
    }
  }.freeze

  def self.toggle(action, undoable_action)
    reversed_action = action == 'undo' ? 'redo' : 'undo'
    {
      action: reversed_action,
      undoable_action: undoable_action,
      text: UNDO_REDO_TEXT[reversed_action][undoable_action]
    }
  end

  def self.presenter(action, undoable_action)
    {
      action: action,
      undoable_action: undoable_action,
      text: UNDO_REDO_TEXT[action][undoable_action]
    }
  end
end
