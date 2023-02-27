ARG APP_DIR="/app"
FROM gitlab/gitlab-runner:latest

RUN apt-get upgrade \
    && apt-get update \
    && apt-get install -y x11-apps\
    && apt-get install -y wget gnupg mesa-va-drivers libva-drm2 libva-x11-2 mesa-utils mesa-utils-extra nodejs npm\
    && apt-get update \
    && apt-get install -y fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    software-properties-common \
    npm
RUN npm install npm@latest -g && \
    npm install n -g && \
    n latest

RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install    

RUN mkdir -p ${FUNCTION_DIR}/

WORKDIR ${FUNCTION_DIR}

COPY src ${FUNCTION_DIR}/src
COPY *.json ${FUNCTION_DIR}/
COPY *.js ${FUNCTION_DIR}/
COPY *.cjs ${FUNCTION_DIR}/
COPY *.sh ${FUNCTION_DIR}/

RUN npm install && \
    npm install puppeteer && \
    chmod -R +x node_modules/puppeteer-chromium && \
    chmod -R +x entrypoint.sh && \
    npm install -g typescript && \
    npm install aws-lambda-ric && \
    tsc

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

ENV HOME="/tmp"

ENTRYPOINT ["entrypoint.sh"]