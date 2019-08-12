# iron-cockroachdb
Secure base image for running CockroachDB databases, which are PostgreSQL-compliant.

Check it out on [Docker Hub](https://hub.docker.com/r/ironpeakservices/iron-cockroachdb)!

## How is this different?
We build from the official cockroachdb releases, but additionally:
- an empty scratch container (no shell, unprivileged user, ...) for a tiny attack vector
- hardened Docker Compose file

## Example
See the `cockroachdb.compose` file.
