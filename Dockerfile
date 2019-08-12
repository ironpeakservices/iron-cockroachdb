FROM alpine:3.10.1 AS builder

# add unprivileged user
RUN adduser -s /bin/true -u 1000 -D -h /app app \
	&& sed -i -r "/^(app|root)/!d" /etc/group /etc/passwd \
	&& sed -i -r 's#^(.*):[^:]*$#\1:/sbin/nologin#' /etc/passwd

# create directory to copy over later
RUN mkdir -p /tmp/c/cockroach/cockroach-data \
    && chmod -R 700 /tmp/c/

# download the cockroachdb binary
ENV COCKROACH_VERSION="v1.1.6"
RUN wget --quiet "https://binaries.cockroachdb.com/cockroach-${COCKROACH_VERSION}.linux-musl-amd64.tgz" -O /tmp/cockroach.tgz && \
    tar xvzf /tmp/cockroach.tgz --strip 1

# ---

# Setup our scratch container
FROM scratch

ENV COCKROACH_CHANNEL=official-docker

# add-in our unprivileged user
COPY --from=builder /etc/passwd /etc/group /etc/shadow /etc/

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

# run the app
ENTRYPOINT ["/cockroach/cockroach"]