RSpec.describe UndoPresenter do
  subject(:undo_presenter) do
    described_class.new(
      action: action,
      undoable_action: undoable_action
    )
  end
  let(:action) { 'undo' }
  let(:undoable_action) { 'move' }

  describe '#undo_presenter' do
    it 'returns an instance of an undo presenter' do
      expect(subject.undo_presenter).to be_a UndoPresenter
    end
  end

  describe 'for undo move' do
    it 'provide text returns the right text' do
      expect(subject.text).to eq(I18n.t('actions.undo_redo.undo_move'))
    end

    it 'toggle to redo move' do
      expect(subject.toggled_presenter[:text]).to eq(I18n.t('actions.undo_redo.redo_move'))
    end
  end

  describe 'for redo change next page' do
    let(:action) { 'redo' }
    let(:undoable_action) { 'change_next_page' }
    it 'provide text returns the right text' do
      expect(subject.text).to eq(I18n.t('actions.undo_redo.redo_change_next_page'))
    end
    it 'toggle to undo change next page' do
      expect(subject.toggled_presenter[:text]).to eq(I18n.t('actions.undo_redo.undo_change_next_page'))
    end
  end
end
