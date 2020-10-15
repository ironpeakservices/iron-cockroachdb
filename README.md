# iron-cockroachdb
Secure base image for running CockroachDB databases, which are PostgreSQL-compliant.

`docker pull ghcr.io/ironpeakservices/iron-cockroachdb:1.0.0`

## How is this different?
We build from the official cockroachdb releases, but additionally:
- an empty scratch container (no shell, unprivileged user, ...) for a tiny attack vector
- healthcheck to verify container health
- hardened Docker Compose file

## Example
See the `cockroachdb.compose` file.

## Update policy
Updates to the official cockroachdb docker image are automatically created as a pull request and trigger linting & a docker build. When those checks complete without errors, a merge into master will trigger a deploy with the same version to packages.

## Insecure
By default this image will start up a server in insecure mode using `--insecure`.
Please configure cockroachdb for secure mode when using it anywhere else than development.
You will need to overwrite the `HEALTHCHECK` directive to use certificates too.
