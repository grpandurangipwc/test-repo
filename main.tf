terraform {
  backend "gcs" {
    bucket = "encv-staging-tf-state"
  }
}

module "en" {
  source = "github.com/google/exposure-notifications-verification-server//terraform?ref=v0.18.5"

  project = "encv-staging"

  create_env_file = true

  adminapi_hosts  = ["adminapi.encv-staging.org"]
  apiserver_hosts = ["apiserver.encv-staging.org"]
  server_hosts    = ["encv-staging.org"]

  enx_redirect_domain     = "en.express"
  enx_redirect_domain_map = []

  service_environment = {
    server = {
      FIREBASE_PRIVACY_POLICY_URL   = "https://policies.google.com/privacy"
      FIREBASE_TERMS_OF_SERVICE_URL = "https://policies.google.com/terms"
      ENFORCE_REALM_QUOTAS          = "true"
      LOG_DEBUG                     = "true"
    }

    apiserver = {
      LOG_DEBUG = "true"
    }

    adminapi = {
      ENFORCE_REALM_QUOTAS = "true"
      LOG_DEBUG            = "true"
    }

    e2e-runner = {
      LOG_DEBUG = "true"

      HEALTH_AUTHORITY_CODE = "e2e-test-only"
      # exposure service on apollo-server-us project.
      KEY_SERVER = "https://dev.exposurenotification.health/v1/publish"
    }

    modeler = {
      LOG_DEBUG = "true"
    }
  }

  db_apikey_db_hmac_count         = 2
  db_apikey_sig_hmac_count        = 2
  db_verification_code_hmac_count = 2
}

module "en-alerting" {
  source                      = "github.com/google/exposure-notifications-verification-server.git//terraform/alerting?ref=main"

  project = "encv-staging"
  #monitoring-host-project="encv-staging"
  #verification-server-project="encv-staging"

  adminapi_hosts  = ["adminapi.encv-staging.org"]
  apiserver_hosts = ["apiserver.encv-staging.org"]
  server_hosts    = ["encv-staging.org"]

  alert-notification-channels = {
    email = {
      labels = {
        email_address = "us_aphl_ens_mvs@pwc.com"
      }
    }
  }
  depends_on = [module.en]
}

output "en" {
  value = module.en
}
