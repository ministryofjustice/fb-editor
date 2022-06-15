Rails.application.config.services_hpa = {
  test_dev: {
    min_replicas: 2,
    max_replicas: 10,
    target_cpu_utilisation: 75
  },
  test_production: {
    min_replicas: 1,
    max_replicas: 2,
    target_cpu_utilisation: 75
  },
  live_dev: {
    min_replicas: 1,
    max_replicas: 2,
    target_cpu_utilisation: 75
  },
  live_production: {
    min_replicas: 2,
    max_replicas: 10,
    target_cpu_utilisation: 75
  }
}
