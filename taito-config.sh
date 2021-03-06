#!/bin/bash

# Taito-cli settings
export taito_image="taitounited/taito-cli:latest"
export taito_extensions=""
# Enabled taito-cli plugins
# - 'docker:local' means that docker is used only in local environment
# - 'kubectl:-local' means that kubernetes is used in all other environments
export taito_plugins=" \
  postgres-db sqitch-db docker:local \
  secrets:-local kube-secrets:-local kubectl:-local helm:-local \
  gcloud:-local gcloud-builder:-local \
  sentry semantic npm git links-global"

# Common project settings for all plugins
export taito_environments="dev prod"
export taito_organization="taitounited"
export taito_zone="gcloud-temp1"
export taito_provider="gcloud"
export taito_repo_location="github-${taito_organization}"
export taito_repo_name="taito-test0"
export taito_project="taito-test0"
export taito_company="taito"
export taito_family=""
export taito_application="test0"
export taito_suffix=""
export taito_namespace="${taito_project}-${taito_env:?}" # or "${taito_company}-${taito_env}"
export taito_registry="eu.gcr.io/${taito_zone}/${taito_repo_location}-${taito_repo_name}"
export taito_app_url="https://${taito_namespace}.taitodev.com"
export taito_admin_url="${taito_app_url}/admin/"

# docker plugin
export dockerfile=Dockerfile

# gcloud plugin
export gcloud_region="europe-west1"
export gcloud_zone="europe-west1-c"
export gcloud_sql_proxy_port="5001"
export gcloud_cdn_enabled=false

# Kubernetes plugin
export kubectl_name="kube1" # TODO rename to common-kubernetes

# Database plugins (postgres/mysql/...)
export database_instance="common-postgres"
export database_name="${taito_project//-/_}_${taito_env}"
export database_host="localhost"
export database_port="${gcloud_sql_proxy_port}"

# Sqitch plugin
export sqitch_engine="pg" # pq/mysql/oracle/sqlite/vertica/firebird

# Template plugin
export template_name="server-template"
export template_source_git="git@github.com:TaitoUnited"

# Sentry plugin
export sentry_organization="${taito_organization}"

# Settings for builds
# NOTE: Most of these should be enabled for dev and feature envs only
export ci_stack="admin client cache database server storage"
export ci_exec_build=false        # build a container if does not exist already
export ci_exec_deploy=true        # deploy automatically
export ci_exec_test=false         # execute test suites after deploy
export ci_exec_test_wait=120      # how many seconds to wait for deployment/restart
export ci_exec_test_init=false    # run 'init --clean' before each test suite
export ci_exec_revert=false       # revert deploy automatically on fail

# Test suite arguments
export test_api_url="${taito_app_url}/api"
export test_user="test"
export test_password="password"

# Override settings for different environments:
# local, feature, dev, test, staging, prod
case "${taito_env}" in
  prod)
    # prod overrides
    export taito_zone="gcloud-temp1"
    export gcloud_region="europe-west1"
    export gcloud_zone="europe-west1"
    ;;
  staging)
    # staging overrides
    export taito_zone="gcloud-temp1"
    export gcloud_region="europe-west1"
    export gcloud_zone="europe-west1"
    ;;
  test)
    # test overrides
    ;;
  dev|feature)
    # dev and feature overrides
    export ci_exec_build=true        # allow build of a new container
    export ci_exec_deploy=true       # deploy automatically
    # NOTE: enable tests once you have implemented some integration or e2e tests
    export ci_exec_test=false        # execute test suites
    export ci_exec_test_init=false   # run 'init --clean' before each test suite
    export ci_exec_revert=false      # revert deploy if previous steps failed
    ;;
  local)
    # local overrides
    export ci_exec_test_init=false   # run 'init --clean' before each test suite
    export test_api_url="http://localhost:3332"
    export taito_app_url="http://localhost:8609"
    export taito_admin_url="${taito_app_url}/admin/"
    export database_external_port="7956"
    export database_host="${taito_project}-database"
    export database_port="5432"
esac

# --- Derived values ---

# gcloud plugin
export gcloud_project="${taito_zone}"

# Kubernetes plugin
export kubectl_cluster="gke_${taito_zone}_${gcloud_zone}_${kubectl_name}"
export kubectl_user="${kubectl_cluster}"

# Link plugin
export link_urls="\
  * app[:ENV]#app=${taito_app_url} \
    Application (:ENV) \
  * admin[:ENV]#admin=${taito_admin_url} \
    Admin user interface (:ENV) \
  * api[:ENV]#app=${taito_app_url}/api/infra/uptimez \
    API (:ENV) \
  * docs=https://github.com/${taito_organization}/${taito_repo_name}/wiki \
    Project documentation \
  * git=https://github.com/${taito_organization}/${taito_repo_name} \
    Git repository \
  * kanban=https://github.com/${taito_organization}/${taito_repo_name}/projects \
    Kanban boards \
  * builds=https://console.cloud.google.com/gcr/builds?project=${taito_zone}&query=source.repo_source.repo_name%3D%22${taito_repo_location}-${taito_repo_name}%22 \
    Build logs \
  * images=https://console.cloud.google.com/gcr/images/${taito_zone}/EU/${taito_repo_location}-${taito_repo_name}?project=${taito_zone} \
    Container images \
  * artifacts=https://TODO-DOCS-AND-TEST-REPORTS \
    Generated documentation and test reports \
  * storage:ENV#storage=https://console.cloud.google.com/storage/browser/${taito_project}-${taito_env}?project=${taito_zone} \
    Storage bucket (:ENV) \
  * logs:ENV#logs=https://console.cloud.google.com/logs/viewer?project=${taito_zone}&minLogLevel=0&expandAll=false&resource=container%2Fcluster_name%2F${kubectl_name}%2Fnamespace_id%2F${taito_namespace} \
    Logs (:ENV) \
  * errors:ENV#errors=https://sentry.io/${taito_organization}/${taito_project}/?query=is%3Aunresolved+environment%3A${taito_env} \
    Sentry errors (:ENV) \
  * uptime=https://app.google.stackdriver.com/uptime?project=${taito_zone} \
    Uptime monitoring (Stackdriver) \
  * feedback=https://TODO-ZENDESK \
    User feedback (Zendesk) \
  * performance=https://TODO-NEW-RELIC \
    Performance metrics (New Relic)"

# Secrets
# NOTE: Secret naming: type.target_of_type.purpose[/namespace]:generation_method
export taito_secrets="
  git.github.build:read/devops
  gcloud.cloudsql.proxy:copy/devops
  db.${database_name}.build/devops:random
  db.${database_name}.app:random
  storage.${taito_project}.gateway:random
  gcloud.${taito_project}-${taito_env}.multi:file
  jwt.${taito_project}.auth:random
  user.${taito_project}-admin.auth:manual
  user.${taito_project}-user.auth:manual"
