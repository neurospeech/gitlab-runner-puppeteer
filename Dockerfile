ARG APP_DIR="/app"
FROM gitlab/gitlab-runner:latest

RUN apk-get upgrade \
    && apk-get update \
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
COPY *.sh ${FUNCTION_DIR}/

RUN npm ci && \
    npm install puppeteer && \
    chmod -R +x node_modules/puppeteer-chromium && \
    chmod -R +x entrypoint.sh && \
    npm install -g typescript && \
    npm install aws-lambda-ric && \
    tsc

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

ENV HOME="/tmp"

ENTRYPOINT ["entrypoint.sh"]