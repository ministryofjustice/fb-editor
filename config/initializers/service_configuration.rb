Rails.application.config.global_service_configuration = {
  strategy: {
    max_surge: '100%',
    max_unavailable: '50%',
  },
  readiness: {
    initial_delay_seconds: 15,
    period_seconds: 5,
    success_threshold: 1
  }
}

Rails.application.config.service_namespace_configuration = {
  test_dev: {
    hpa: {
      min_replicas: 2,
      max_replicas: 10,
      target_cpu_utilisation: 75
    }
  },
  test_production: {
    hpa: {
      min_replicas: 1,
      max_replicas: 2,
      target_cpu_utilisation: 75
    }
  },
  live_dev: {
    hpa: {
      min_replicas: 1,
      max_replicas: 2,
      target_cpu_utilisation: 75
    }
  },
  live_production: {
    hpa: {
      min_replicas: 2,
      max_replicas: 10,
      target_cpu_utilisation: 75
    }
  }
}
