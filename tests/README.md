## Install dependencies

```console
git clone https://github.com/tklx/bats.git
bats/install.sh /usr/local
```

## Run the tests

```console
IMAGE=tklx/postgres bats --tap tests/basics.bats

init: running tklx/postgres
init: waiting for tklx/postgres to accept connections.......
1..6
ok 1 create empty table test
ok 2 test insert
ok 3 test insert 2
ok 4 test delete
ok 5 test select
ok 6 test drop
