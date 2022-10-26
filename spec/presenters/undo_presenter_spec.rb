RSpec.describe UndoPresenter do
  let(:action) { 'undo' }
  let(:undoable_action) { 'move' }

  describe 'for undo move' do
    it 'returns the right text' do
      expect(UndoPresenter::UNDO_REDO_TEXT[action][undoable_action]).to eq(I18n.t('actions.undo_redo.undo_move'))
    end

    it 'returns the right presenter' do
      expect(UndoPresenter.presenter(action, undoable_action)).to eq(
        {
          action: 'undo',
          undoable_action: 'move',
          text: I18n.t('actions.undo_redo.undo_move')
        }
      )
    end

    it 'toggle to redo move presenter' do
      expect(UndoPresenter.toggle(action, undoable_action)).to eq(
        {
          action: 'redo',
          undoable_action: 'move',
          text: I18n.t('actions.undo_redo.redo_move')
        }
      )
    end
  end

  describe 'for redo change next page' do
    let(:action) { 'redo' }
    let(:undoable_action) { 'change_next_page' }
    it 'returns the right text' do
      expect(UndoPresenter::UNDO_REDO_TEXT[action][undoable_action]).to eq(I18n.t('actions.undo_redo.redo_change_next_page'))
    end

    it 'returns the right presenter' do
      expect(UndoPresenter.presenter(action, undoable_action)).to eq(
        {
          action: 'redo',
          undoable_action: 'change_next_page',
          text: I18n.t('actions.undo_redo.redo_change_next_page')
        }
      )
    end

    it 'toggle to redo move presenter' do
      expect(UndoPresenter.toggle(action, undoable_action)).to eq(
        {
          action: 'undo',
          undoable_action: 'change_next_page',
          text: I18n.t('actions.undo_redo.undo_change_next_page')
        }
      )
    end
  end
end
