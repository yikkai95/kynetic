# Type must be "single-container" or "multi-container"
TYPE=$1
source ./.env
curl --user admin:admin -H 'X-Requested-By:admin' -X POST $AMBARI_HOST/api/v1/blueprints/single-container-kylin --data-binary "@examples/blueprints/$TYPE.json"
curl --user admin:admin -H 'X-Requested-By:admin' -X PUT $AMBARI_HOST/api/v1/stacks/HDP/versions/$HDP_VERSION/operating_systems/$OS/repositories/HDP-${HDP_VERSION} -d '{"Repositories":{"base_url":"'$BASE_URL'", "verify_base_url":true}}'
curl --user admin:admin -H 'X-Requested-By:admin' -X POST $AMBARI_HOST/api/v1/clusters/dev --data-binary "@examples/hostgroups/$TYPE.json"
