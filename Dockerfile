ARG GITLAB_RUNNER_IMAGE_TYPE
ARG GITLAB_RUNNER_IMAGE_TAG
ARG GITLAB_INSTANCE
ARG GITLAB_TOKEN
ARG APP_DIR="/app"
FROM gitlab/${GITLAB_RUNNER_IMAGE_TYPE}:${GITLAB_RUNNER_IMAGE_TAG}

RUN apk update
RUN apk upgrade

RUN apt-get update \
    && apt-get install -y x11-apps\
    && apt-get install -y wget gnupg chromium mesa-va-drivers libva-drm2 libva-x11-2 mesa-utils mesa-utils-extra nodejs npm\
    && apt-get update \
    && apt-get install -y fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${FUNCTION_DIR}/

WORKDIR ${FUNCTION_DIR}

COPY src ${FUNCTION_DIR}/src
COPY *.json ${FUNCTION_DIR}/
COPY *.js ${FUNCTION_DIR}/
COPY *.cjs ${FUNCTION_DIR}/

RUN npm ci && \
    npm install puppeteer && \
    chmod -R +x node_modules/puppeteer-chromium && \
    npm install -g typescript && \
    npm install aws-lambda-ric && \
    tsc

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

ENV HOME="/tmp"


RUN --rm -v /srv/gitlab-runner/config:/etc/gitlab-runner gitlab/gitlab-runner register &&\
  --non-interactive &&\
  --executor "docker" &&\
  --docker-image alpine:latest &&\
  --url ${GITLAB_INSTANCE} &&\
  --registration-token ${GITLAB_TOKEN} &&\
  --description "docker-runner" &&\
  --maintenance-note "Free-form maintainer notes about this runner" &&\
  --tag-list "docker,aws" &&\
  --run-untagged="true" &&\
  --locked="false" &&\
  --access-level="not_protected"