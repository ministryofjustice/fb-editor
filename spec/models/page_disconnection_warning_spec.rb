RSpec.describe PageDisconnectionWarning do
  subject(:verify_potential_grid) do
    described_class.new(
      current_grid: current_grid,
      potential_grid: potential_grid
    )
  end

  describe '#show_warning?' do
    let(:metadata) { metadata_fixture(:branching_4) }
    let(:potential_metadata) { metadata }
    let(:current_grid) do
      MetadataPresenter::Grid.new(MetadataPresenter::Service.new(metadata))
    end
    let(:potential_grid) do
      MetadataPresenter::Grid.new(MetadataPresenter::Service.new(potential_metadata))
    end

    context 'when the potential service has submitting pages' do
      let(:potential_metadata) { metadata_fixture(:branching_4) }

      context 'when current service has submitting pages' do
        it 'does not trigger a warning' do
          expect(verify_potential_grid.show_warning?).to be_falsey
        end
      end

      context 'when current service does not have submitting pages' do
        let(:metadata) do
          meta = metadata_fixture(:branching_4)
          meta['pages'].pop # remove confirmation page
          meta['flow'] = meta['flow'].except!('778e364b-9a7f-4829-8eb2-510e08f156a3') # confirmation
          meta['flow']['e337070b-f636-49a3-a65c-f506675265f0']['next']['default'] = '' # checkanswers
          meta
        end

        it 'does not trigger a warning' do
          expect(verify_potential_grid.show_warning?).to be_falsey
        end
      end

      context 'when current service has detached submitting pages' do
        let(:metadata) do
          meta = metadata_fixture(:branching_4)
          meta['flow']['e337070b-f636-49a3-a65c-f506675265f0']['next']['default'] = '' # checkanswers
          meta
        end

        it 'does not trigger a warning' do
          expect(verify_potential_grid.show_warning?).to be_falsey
        end
      end
    end

    context 'when the potential service does not have submitting pages' do
      let(:potential_metadata) do
        meta = metadata_fixture(:branching_4)
        meta['pages'].pop # remove confirmation page
        meta['flow'] = meta['flow'].except!('778e364b-9a7f-4829-8eb2-510e08f156a3') # confirmation
        meta['flow']['e337070b-f636-49a3-a65c-f506675265f0']['next']['default'] = '' # checkanswers
        meta
      end

      context 'current service does not have submitting pages' do
        let(:metadata) do
          meta = metadata_fixture(:branching_4)
          meta['pages'].pop # remove confirmation page
          meta['flow'] = meta['flow'].except!('778e364b-9a7f-4829-8eb2-510e08f156a3') # confirmation
          meta['flow']['e337070b-f636-49a3-a65c-f506675265f0']['next']['default'] = '' # checkanswers
          meta
        end

        it 'does not trigger a warning' do
          expect(verify_potential_grid.show_warning?).to be_falsey
        end
      end

      context 'when current service has submitting pages' do
        it 'triggers a warning' do
          expect(verify_potential_grid.show_warning?).to be_truthy
        end
      end

      context 'when current service has detached submitting pages' do
        let(:metadata) do
          meta = metadata_fixture(:branching_4)
          meta['flow']['e337070b-f636-49a3-a65c-f506675265f0']['next']['default'] = '' # checkanswers
          meta
        end

        it 'does not trigger a warning' do
          expect(verify_potential_grid.show_warning?).to be_falsey
        end
      end
    end

    context 'when the potential service has detached submitting pages' do
      let(:potential_metadata) do
        meta = metadata_fixture(:branching_4)
        meta['flow']['e337070b-f636-49a3-a65c-f506675265f0']['next']['default'] = '' # checkanswers
        meta
      end

      context 'when current service has submitting pages' do
        it 'triggers a warning' do
          expect(verify_potential_grid.show_warning?).to be_truthy
        end
      end
    end

    context 'when current service has detached submitting pages' do
      let(:metadata) do
        meta = metadata_fixture(:branching_4)
        meta['flow']['e337070b-f636-49a3-a65c-f506675265f0']['next']['default'] = '' # checkanswers
        meta
      end

      it 'does not trigger a warning' do
        expect(verify_potential_grid.show_warning?).to be_falsey
      end
    end
  end
end
