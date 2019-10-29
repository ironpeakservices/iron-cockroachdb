# iron-cockroachdb
Secure base image for running CockroachDB databases, which are PostgreSQL-compliant.

`docker pull docker.pkg.github.com/ironpeakservices/iron-cockroachdb/iron-cockroachdb:19.1.5`

## How is this different?
We build from the official cockroachdb releases, but additionally:
- an empty scratch container (no shell, unprivileged user, ...) for a tiny attack vector
- hardened Docker Compose file

## Example
See the `cockroachdb.compose` file.

## Update policy
Updates to the official cockroachdb docker image are automatically created as a pull request and trigger linting & a docker build. When those checks complete without errors, a merge into master will trigger a deploy with the same version to packages.
