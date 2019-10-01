FROM docker

RUN apk --no-cache add ca-certificates && apk add curl python bash

# Downloading gcloud package
RUN curl -k https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

# Installing the package
RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz


# Adding the package path to local
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

ARG VERSION=1.5.0
ARG OS=linux
ARG ARCH=amd64

RUN curl -fksSL "https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v${VERSION}/docker-credential-gcr_${OS}_${ARCH}-${VERSION}.tar.gz" \
  | tar xz --to-stdout ./docker-credential-gcr \
  > /usr/bin/docker-credential-gcr && chmod +x /usr/bin/docker-credential-gcr

COPY vulnerability_parser /usr/local/bin/
RUN chmod +x /usr/local/bin/vulnerability_parser

RUN which docker-credential-gcr
RUN which vulnerability_parser

RUN docker-credential-gcr configure-docker
