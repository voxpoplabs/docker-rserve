# vim:set ft=dockerfile:
FROM rocker/r-base

MAINTAINER "Steven Pollack" steven@gnobel.com

RUN apt-get update && \
    apt-get install -y \
    jags \
    libcurl4-openssl-dev \
    libssl-dev && \
    apt-get clean  && \
    rm -rf /var/lib/apt/lists/

RUN install2.r --error \
    -r "https://cran.rstudio.com" \
    devtools \
    randomForest \
    rjags \
    Rserve \
    stringr && \
    Rscript -e " \
    options(unzip = 'internal'); \
    httr::set_config( httr::config( ssl_verifypeer = 0L ) ); \
    devtools::install_github('rasmusab/bayesian_first_aid')" && \ 
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds

RUN install2.r --error \
    -r "http://www.bioconductor.org/packages/release/bioc" \
    hopach

# you have to run Rserve with remote=TRUE otherwise
# it won't let you connect to the container
EXPOSE 6311
ENTRYPOINT R -e "\
library(randomForest); \
library(stringr); \
library(BayesianFirstAid); \
library(hopach); \
Rserve::run.Rserve(remote=TRUE)"

