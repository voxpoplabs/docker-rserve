FROM debian:8.3

MAINTAINER "Steven Pollack" steven@gnobel.com

RUN apt-get update && apt-get install -y \
    bzip2 \
    wget

RUN wget -O miniconda3.sh http://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x miniconda3.sh && \
    ./miniconda3.sh -b && \
    rm ./miniconda3.sh

ENV PATH /root/miniconda3/bin:$PATH

RUN conda install -y --channel r \
    r-rserve

# link libssl and libcrypto SO's
RUN cd /root/miniconda3/lib && \
    ln -fs libssl.so libssl.so.6 && \
    ln -fs libcrypto.so libcrypto.so.6

# you have to run Rserve with remote=TRUE otherwise
# it won't let you connect to the container
EXPOSE 6311
ENTRYPOINT R -e "Rserve::run.Rserve(remote=TRUE)"
