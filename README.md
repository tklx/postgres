# tklx/postgresql - SQL database

[![CircleCI](https://circleci.com/gh/tklx/postgres.svg?style=shield)](https://circleci.com/gh/tklx/postgres)

[PostgreSQL][postgres], often simply Postgres, is an object-relational database management system (ORDBMS) with an emphasis on extensibility and standards-compliance. As a database server, its primary function is to store data securely, and to allow for retrieval at the request of other software applications. It can handle workloads ranging from small single-machine applications to large Internet-facing applications with many concurrent users.

## Features

- Based on the super slim [tklx/base][base] (Debian GNU/Linux).
- PostgreSQL installed directly from Debian.
- Uses [tini][tini] for zombie reaping and signal forwarding.
- Uses [gosu][gosu] for dropping privileges to postgres user.
- Includes ``VOLUME /var/lib/postgresql/data`` for persistence.
- Includes ``EXPOSE 5432``, so standard container linking will make it
  automatically available to the linked containers.

## Usage

### Start a postgres instance and connect to it from an application

```console
$ docker run --name some-postgres -e POSTGRES_PASSWORD='secretpass' -d tklx/postgres
$ docker run --name some-app --link some-postgres:postgres -d app-that-uses-postgres
```

### Initialization

The image can be initialized by passing the following options as [environment variables][1] to ```docker run```:

    PGDATA            - Postgres data location (/var/lib/postgresql/data by default)
    POSTGRES_DB       - name of database to initialize
    POSTGRES_USER     - name of database user to assign as owner of POSTGRES_DB
    POSTGRES_PASSWORD - password for database user or ```postgres``` if user not specified

```POSTGRES_PASSWORD``` is required for remote access (e. g. from linked containers). If it is not supplied and the datastore was not already initialized, only local access will be allowed.

### Tips

```console
# postgresql client options
$ docker run --rm tklx/postgresql psql --help

# postgres options
$ docker run --rm tklx/postgresql --help

# launch a regular PostgreSQL instance
$ docker run --name some-postgres -e POSTGRES_USER=someuser POSTGRES_DB=somedb -e POSTGRES_PASSWORD=mysecretpassword -d tklx/postgres

# link an application to it
$ docker run --name some-app --link some-postgres:tklx/postgres -d app-that-uses-postgres

# access through psql
$ docker run -it --rm --link some-postgres:tklx/postgres tklx/postgres psql -h postgres -U postgres
psql (9.4.8)
Type "help" for help.

postgres=# SELECT 1;
 ?column? 
----------
        1
(1 row)

# local access through psql
$ docker exec -it some-postgres psql -h localhost -U postgres

```

## Automated builds

The [Docker image](https://hub.docker.com/r/tklx/postgres/) is built, tested and pushed by [CircleCI](https://circleci.com/gh/tklx/postgres) from source hosted on [GitHub](https://github.com/tklx/postgres).

* Tag: ``x.y.z`` refers to a [release](https://github.com/tklx/mongodb/releases) (recommended).
* Tag: ``latest`` refers to the master branch.

## Status

Currently on major version zero (0.y.z). Per [Semantic Versioning][semver],
major version zero is for initial development, and should not be considered
stable. Anything may change at any time.

## Issue Tracker

TKLX uses a central [issue tracker][tracker] on GitHub for reporting and
tracking of bugs, issues and feature requests.

[postgres]: https://www.postgresql.org/
[base]: https://github.com/tklx/base
[tini]: https://github.com/krallin/tini
[gosu]: https://github.com/tianon/gosu
[semver]: http://semver.org/
[tracker]: https://github.com/tklx/tracker/issues
