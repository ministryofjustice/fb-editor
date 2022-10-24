class UndoPresenter
  attr_accessor :action, :undoable_action
  attr_reader :text

  def initialize(action:, undoable_action:, text: '')
    @action = action
    @undoable_action = undoable_action
    @text = self.class.provide_text_undo(action, undoable_action)
  end

  def toggled_presenter
    if @text == I18n.t('actions.undo_redo.undo_move')
      {
        action: 'redo',
        undoable_action: 'move',
        text: I18n.t('actions.undo_redo.redo_move')
      }
    elsif @text == I18n.t('actions.undo_redo.undo_change_next_page')
      {
        action: 'redo',
        undoable_action: 'change_next_page',
        text: I18n.t('actions.undo_redo.redo_change_next_page')
      }
    elsif @text == I18n.t('actions.undo_redo.redo_move')
      {
        action: 'undo',
        undoable_action: 'move',
        text: I18n.t('actions.undo_redo.undo_move')
      }
    elsif @text == I18n.t('actions.undo_redo.redo_change_next_page')
      {
        action: 'undo',
        undoable_action: 'change_next_page',
        text: I18n.t('actions.undo_redo.undo_change_next_page')
      }
    end
  end

  def self.provide_text_undo(action, undoable_action)
    case action
    when 'undo'
      case undoable_action
      when 'change_next_page'
        I18n.t('actions.undo_redo.undo_change_next_page')
      when 'move'
        I18n.t('actions.undo_redo.undo_move')
      end
    when 'redo'
      case undoable_action
      when 'change_next_page'
        I18n.t('actions.undo_redo.redo_change_next_page')
      when 'move'
        I18n.t('actions.undo_redo.redo_move')
      end
    end
  end

  def undo_presenter
    @undo_presenter ||= UndoPresenter.new(
      action: action,
      undoable_action: undoable_action,
      text: self.class.provide_text_undo(action, undoable_action)
    )
  end
end
