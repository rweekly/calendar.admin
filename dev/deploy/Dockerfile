FROM ubuntu:latest

# install curl
RUN apt update -y
RUN apt install curl -y

# Get a default.nix with R and rix
RUN curl -O https://raw.githubusercontent.com/ropensci/rix/main/inst/extdata/default.nix

# Install nix package manager from determinate systems
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux \
  --extra-conf "sandbox = false" \
  --init none \
  --no-confirm

# Set env vars for Nix installation
ENV PATH="${PATH}:/nix/var/nix/profiles/default/bin"
ENV INSTALL_APP_PACKAGE=1
ENV user=root

# Copy bootstrapping env script
COPY build_nixconfig.R .

# Copy app driver script
COPY driver.R .

# Copy package source installer file
COPY calendar.admin_*.tar.gz app.tar.gz

# Set up rstats-on-nix cache
# No need to use the cachix client inside Docker
RUN nix-shell --run "Rscript -e 'rix::setup_cachix()'"

# This will overwrite the default.nix we downloaded with a new one
RUN nix-shell --run "Rscript build_nixconfig.R"

# build the environment
RUN nix-build

# trick to cache the package deps a sa layer
RUN nix-shell --run exit

ARG shiny_port_value=1557
ENV SHINY_PORT=${shiny_port_value}

# expose necessary port
EXPOSE ${shiny_port_value}

# Run application driver script
#CMD nix-shell --run "Rscript driver.R"
#CMD ["nix-shell", "--run", "Rscript driver.R"]
CMD ["nix-shell", "--run", "Rscript -e \"options(shiny.port=as.numeric(Sys.getenv('SHINY_PORT')), shiny.host='0.0.0.0', auth0_config_file=system.file('app/_auth0.yml',package='calendar.admin'), auth0_disable=FALSE); library(calendar.admin); calendar.admin::run_app()\""]
