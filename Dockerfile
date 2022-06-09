# First build
FROM public.ecr.aws/docker/library/node:16-alpine AS build

# The base node image sets a very verbose log level.
ENV NPM_CONFIG_LOGLEVEL=warn \
    NODE_OPTIONS=--max_old_space_size=4096 \
    INSTALL_PATH=/react-container

# This sets the context of where commands will be ran in and is documented
# on Docker's website extensively.
WORKDIR $INSTALL_PATH

# If set - `yarn install` will not be executed
# dev env uses volume for the node_modules so `yarn install` step doesn't make sense for the dev env
# but it makes sense for the isolated env, that is why we use this arg
ARG DEV_ENV
ENV DEV_ENV=$DEV_ENV

ARG app_version_arg=1
ENV APP_VERSION=$app_version_arg

# Caching deps
COPY ./package.json ./yarn.lock $INSTALL_PATH/
RUN if [ -z "$DEV_ENV" ]; then yarn --silent; fi

# Add in the application code from your work station at the current directory
# over to the working directory.
COPY . $INSTALL_PATH


# Second build - final Docker image.
FROM public.ecr.aws/docker/library/node:16-alpine

ENV NODE_OPTIONS=--max_old_space_size=4096 \
    INSTALL_PATH=/react-container
WORKDIR $INSTALL_PATH

EXPOSE 3000

COPY --from=build $INSTALL_PATH $INSTALL_PATH
