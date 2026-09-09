RSpec.shared_examples 'a controller that stores the current request details' do
  let(:headers) { { 'X-Request-Id' => request_id } }
  let(:request_id) { '12345' }

  it 'stores the current `request_id`' do
    expect(Current).to receive(:request_id=).with(request_id)
    get path, headers:
  end
end
