# R Weekly Curation Calendar Admin Application Developer Guide

This document contains additional details on setting up a development
environment for building the R Weekly Curation Calendar Admin application as
well as information on additional services utilized in the backend. 

## Development Environment

This project uses the [Nix package manager](https://nixos.org/) to install the
development libraries used to create and execute the application. The Nix
configuration files was created using the
[`{rix}`](https://docs.ropensci.org/rix/index.html) R package. To set up the
development environment, follow the instructions below:

* Install the [Determinant
  Nix](https://determinate.systems/posts/determinate-nix-installer) installer on
  your system.
* Run the following command in a terminal to establish a nix-shell ready for
  creating the Nix configuration file:

```bash
nix-shell --expr "$(curl -sl https://raw.githubusercontent.com/ropensci/rix/main/inst/extdata/default.nix)"
```

* In the same prompt, launch R and run the following command to create a new file called `default.nix` in the root of your local copy of the repository:

```r
source("dev/deploy/build_nixconfig.R")
```

* Exit R and exit from the nix shell by typing `exit` in the terminal.
* Initialize the Nix environment by running `nix-build` in the terminal. Note
  that this could take a few minutes depending on bandwidth.
* Activate the development environment by running `nix-shell` in the terminal. 

## Environment Variables

Each of the services discussed in this document require authentication keys stored as environment variables. The `.env.example` file contains the variables alongside placeholder keys. Contact the author of this application for the real values of these variables and create a new `.env` file in the root of this repository with the correct values. Note that this file will not be version-controlled.

## Authentication

This application uses the [Auth0](https://auth0.com/) service to let the user
authenticate via their Slack ID, as the R Weekly team uses Slack for managing
team communication. When executing the application in development mode, the Auth0
portal is bypassed and a test user is automatically tracked in the application.
If you want to execute the Auth0 login portal in a development context, edit the
`dev/run_dev.R` script and set `options(auth0_disable = FALSE)`. Make sure to
switch it back to `options(auth0_disable = TRUE)` after finishing your ad-hoc
testing.

Note: When using the Auth0 feature, you must open the application in a web
browser tab. The RStudio viewer tab as well as Visual Studio Code's internal app
viewer tab are not able to render the application correctly.

## Deployment container instructions

### Build Docker Images on Local System

To build the Docker images, navigate to the `dev/deploy` directory and run the following build commands:

```bash
docker build -f Dockerfile -t rpodcast/calendar.admin .
```

Verify that the container version of the application runs correctly on your local development system. Note the port number you map from the host OS to the container needs to be registered in the Auth0 list of callback URLs. Also, note that the `.env` file reference in the command contains the credentials necessary for the application to authenticate to the required services. In this example, the environment file has been copied to the `dev/deploy` directory (without being version-controlled):

```
docker run --rm --env-file .env -p 2557:2557 --name calendartest rpodcast/calendar.admin:latest
```

In a web browser, visit `http://localhost:2557`.

**SIDE NOTE**: If you encounter errors or other issues with the app, here's a general procedure for debugging:

* Stop the docker container

```bash
docker stop calendartest
```

* Modify source code of application as needed. Ensure that you bump the package version in `DESCRIPTION` either manually or running `usethis::use_version("dev", push = FALSE)`.
* Run these snippets from `dev/03_deploy.R` to refresh package build

```r
# dev/03_deploy.R
unlink("dev/deploy/*.tar.gz")
devtools::build(path = "dev/deploy")
```

* Re-build the Docker container image

```bash
docker build -f Dockerfile -t rpodcast/calendar.admin .

```

* Run the container again

```bash
docker run --rm --env-file .env -p 2557:2557 --name calendartest rpodcast/calendar.admin:latest
```

### Push Docker Images to Dockerhub

Ensure that you are able to push to Docker Hub by running the following command to log in to the service and set credentials for future operations:

```bash
docker login -u rpodcast
```

Once the login is successful run the following:

```bash
docker push rpodcast/calendar.admin
```

## Using GitHub Actions

### Running GitHub Action Locally

Use the novel [act](https://nektosact.com/) tool to run GitHub actions locally with Docker. Here is a command to test the docker build & push workflow file:

```
act --secret-file dev/deploy/.env -W '.github/workflows/build-push.yml'
```

## App Deployment

Procedure adapted from <https://hosting.analythium.io/make-your-shiny-app-fly/>

1. Install the `flyctl` command line tool
1. Authenticate to the service using this command:

```
flyctl auth login
```

1. Launch application on service

```
flyctl launch --image rpodcast/rph2024.haunted:latest
```

2. After deployment is complete, you need to add the environment variables using following commands (repeat for each variable until I find a better way):

```
fly secrets set OPENAI_API_KEY=changeme
fly secrets set AUTH0_USER=changeme
fly secrets set AUTH0_KEY=changeme
fly secrets set AUTH0_SECRET=changeme
```

Deploy to fly.io

```bash
fly launch -c fly-staging.toml
```

Adding secrets to fly.io app

```bash
cat .env | tr '\n' ' ' | xargs flyctl secrets -a rwcaladmin-staging set
```

### Deployment inside github actions

```
# run this to make sure an app is created in the system
# this will error if the app exists, hence in GH action need to add flag for continuing to next step if error occurs in this step
fly apps create rwcaladmin

# deploy from the configuraiton file
flyctl deploy -c fly-prod.toml

# adding secrets if running locally
cat .env | tr '\n' ' ' | xargs flyctl secrets -a rwcaladmin set

# adding secrets in GH action
echo "AUTH0_KEY=$AUTH0_KEY AUTH0_SECRET=$AUTH0_SECRET AUTH0_USER=$AUTH0_USER DOLTHUB_CREDS=$DOLTHUB_CREDS DOLTHUB_JWK=$DOLTHUB_JWK DOLTHUB_TOKEN=$DOLTHUB_TOKEN SLACK_TEAM_ID=$SLACK_TEAM_ID SLACK_TEST_USER_ID=$SLACK_TEST_USER_ID SLACK_TOKEN=$SLACK_TOKEN" | xargs flyctl secrets -a rwcaladmin set
```