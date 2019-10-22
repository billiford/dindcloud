FROM docker:18.09.7

RUN apk --no-cache add ca-certificates && apk add curl python bash jq iptables

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


RUN which docker-credential-gcr

#get updated root certs (expiring https://google.com(2025) and https://dl.google.com(2043))
COPY certs/dl.google.com-primary.pem .
COPY certs/google.com-primary.pem .

#paste updated certs into python lib
RUN cat dl.google.com-primary.pem >> /usr/local/gcloud/google-cloud-sdk/lib/third_party/httplib2/python2/httplib2/cacerts.txt
RUN cat google.com-primary.pem >> /usr/local/gcloud/google-cloud-sdk/lib/third_party/httplib2/python2/httplib2/cacerts.txt

#include beta capabilities in container
RUN gcloud components install beta --quiet

RUN docker-credential-gcr configure-docker
