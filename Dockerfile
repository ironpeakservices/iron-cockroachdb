FROM cockroachdb/cockroach:v21.1.5 AS cdb

# make a pipe fail on the first failure
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN /cockroach/cockroach version | grep 'Tag' | cut -d 'v' -f 2 > /cockroach.version

#
# ---
#

FROM alpine:3.14.0 AS builder

# make a pipe fail on the first failure
SHELL ["/bin/sh", "-o", "pipefail", "-c"]

COPY --from=cdb /cockroach.version /

# add unprivileged user
RUN adduser -s /bin/true -u 1000 -D -h /app app \
	&& sed -i -r "/^(app|root)/!d" /etc/group /etc/passwd \
	&& sed -i -r 's#^(.*):[^:]*$#\1:/sbin/nologin#' /etc/passwd

# create directory to copy over later
RUN mkdir -p /tmp/c/cockroach/cockroach-data \
    && chmod -R 700 /tmp/c/
    
# install timezone data
# hadolint ignore=DL3018
RUN apk add --no-cache tzdata

# download the cockroachdb binary
RUN export COCKROACH_VERSION && COCKROACH_VERSION="v$(cat /cockroach.version)" \
    && wget --quiet "https://binaries.cockroachdb.com/cockroach-${COCKROACH_VERSION}.linux-musl-amd64.tgz" -O /tmp/cockroach.tgz \
    && tar xvzf /tmp/cockroach.tgz --strip 1

#
# ---
#

# Setup our scratch container
FROM scratch

ENV COCKROACH_CHANNEL=official-docker

# add-in our unprivileged user
COPY --from=builder /etc/passwd /etc/group /etc/shadow /etc/

# add-in timezone data
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

# add-in our directory with correct permissions
COPY --from=builder --chown=app /tmp/c/ /

# add-in our CA certificates to validate them when connecting to stuff
COPY --from=builder /etc/ssl/certs/ /etc/ssl/certs/

# copy our app 
COPY --from=builder /cockroach /cockroach/cockroach

# run as our unprivileged user instead of root
USER app

# cockroach working directory
WORKDIR /cockroach/

# cockroach ports
EXPOSE 26257 8080

# persistent storage
VOLUME /cockroach/cockroach-data

# healthcheck for db
# TODO: overwrite when not doing --insecure
HEALTHCHECK --interval=10s --timeout=10s --start-period=5s --retries=3 CMD [ "/cockroach/cockroach", "sql", "--insecure", "-e", "SELECT 1" ]

# run the app
ENTRYPOINT ["/cockroach/cockroach"]
