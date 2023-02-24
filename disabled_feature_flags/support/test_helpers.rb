module TestHelpers
  def generate_service_name
    "Acceptance-Test-#{SecureRandom.alphanumeric}"
  end
end
