#!/usr/bin/env bats

# Run these tests from the repo root directory, for example
# bats tests

load functions.sh

function setup {
  basic_setup

  echo "# Starting container using: docker run --rm -u "$MOUNTUID:$MOUNTGID" --rm -v $VOLUME:/var/lib/mysql --mount "type=bind,src=$PWD/test/testdata,target=/mnt/ddev_config" --name=$CONTAINER_NAME -p $HOSTPORT:3306 -d $IMAGE" >&3
  docker run --rm -u "$MOUNTUID:$MOUNTGID" --rm -v $VOLUME:/var/lib/mysql --mount "type=bind,src=$PWD/test/testdata/custom_config,target=/mnt/ddev_config" --name=$CONTAINER_NAME -p $HOSTPORT:3306 -d $IMAGE
  containercheck
}

@test "test with custom_config/mysql/collation.cnf override ${DB_TYPE} ${DB_VERSION}" {
  docker exec $CONTAINER_NAME sh -c 'grep collation-server /mnt/ddev_config/mysql/collation.cnf'
  mysql ${SKIP_SSL:-} --user=root --password=root --skip-column-names --host=127.0.0.1 --port=$HOSTPORT -e "SHOW GLOBAL VARIABLES like \"collation_server\";" | grep "latin1_swedish_ci"
}



