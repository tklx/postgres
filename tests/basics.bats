# based on: docker-library/official-images/test/tests/postgres-basics/run.sh

fatal() { echo "fatal [$(basename $BATS_TEST_FILENAME)]: $@" 1>&2; exit 1; }

_in_cache() {
    IFS=":"; img=($1); unset IFS
    [[ ${#img[@]} -eq 1 ]] && img=("${img[@]}" "latest")
    [ "$(docker images ${img[0]} | grep ${img[1]} | wc -l)" = "1" ] || return 1
}

[ "$IMAGE" ] || fatal "IMAGE envvar not set"
_in_cache $IMAGE || fatal "$IMAGE not in cache"

export POSTGRES_USER='my cool postgres user'
export POSTGRES_PASSWORD='my cool postgres password'
export POSTGRES_DB='my cool postgres database'

psql() {
    docker run --rm -i \
        --link "$CNAME":postgres \
        --entrypoint psql \
        -e PGPASSWORD="$POSTGRES_PASSWORD" \
        "$IMAGE" \
        --host postgres \
        --username "$POSTGRES_USER" \
        --dbname "$POSTGRES_DB" \
        --no-align --tuples-only \
        "$@"
}

_init() {
    export TEST_SUITE_INITIALIZED=y

    echo >&2 "init: running $IMAGE"
    export CNAME="postgres-$RANDOM-$RANDOM"
    export CID="$(docker run -d --name "$CNAME" -e POSTGRES_PASSWORD -e POSTGRES_USER -e POSTGRES_DB "$IMAGE")"
    [ "$CIRCLECI" = "true" ] || trap "docker rm -vf $CID > /dev/null" EXIT

    echo -n >&2 "init: waiting for $IMAGE to accept connections"
    tries=10
    while ! echo 'SELECT 1' | psql &> /dev/null; do
        (( tries-- ))
        if [ $tries -le 0 ]; then
            echo >&2 "$IMAGE failed to accept connections in wait window!"
            ( set -x && docker logs "$CID" ) >&2 || true
            false
        fi
        echo >&2 -n .
        sleep 2
    done
    echo
}
[ -n "$TEST_SUITE_INITIALIZED" ] || _init


@test "create empty table test" {
    echo 'CREATE TABLE test (a INT, b INT, c VARCHAR(255))' | psql
    [ "$(echo 'SELECT COUNT(*) FROM test' | psql)" = 0 ]
}

@test "test insert" {
psql <<'EOSQL'
    INSERT INTO test VALUES (1, 2, 'hello')
EOSQL
    [ "$(echo 'SELECT COUNT(*) FROM test' | psql)" = 1 ]
}

@test "test insert 2" {
psql <<'EOSQL'
    INSERT INTO test VALUES (2, 3, 'goodbye!')
EOSQL
    [ "$(echo 'SELECT COUNT(*) FROM test' | psql)" = 2 ]
}

@test "test delete" {
echo 'DELETE FROM test WHERE a = 1' | psql
    [ "$(echo 'SELECT COUNT(*) FROM test' | psql)" = 1 ]
}

@test "test select" {
    [ "$(echo 'SELECT c FROM test' | psql)" = 'goodbye!' ]
}

@test "test drop" {
    echo 'DROP TABLE test' | psql
    [ "$(echo "SELECT COUNT(*) FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema'" | psql)" = 0 ]
}

