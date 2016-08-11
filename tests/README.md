## Install dependencies

```console
git clone https://github.com/tklx/bats.git
bats/install.sh /usr/local
```

## Run the tests

```console
IMAGE=tklx/postgres bats --tap tests/basics.bats

init: running tklx/postgres
init: waiting for tklx/postgres to accept connections...

