## 0.1.0

Initial development release.

#### Notes

- Based off [tklx/base:0.1.0](https://github.com/tklx/base/releases/tag/0.1.0).
- PostgreSQL installed directly from Debian.
- Uses tini for zombie reaping and signal forwarding.
- Uses gosu for dropping privileges to postgres user.
- Includes ``VOLUME /var/lib/postgresql/data`` for persistence.
- Includes ``EXPOSE 5432`` for container linking.
- Basic bats testing suite.

