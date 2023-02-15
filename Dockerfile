# IMAGE
FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

# GENERAL TOOLS
RUN apt-get update -y && \
    apt-get install apt-utils -y && \
    apt-get install git curl build-essential -y && \
    apt install software-properties-common -y && \
    apt-get install time -y && \
    apt-get install vim -y

# SQLITE
RUN apt-get update -y && \
    apt-get install sqlite3
    
# PYTHON
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update -y && \
    apt-get install python3.8 python3-pip python3.8-distutils -y && \
    python3.8 -m pip install pipenv 

# SHARING AREA BETWEEN HOST AND DOCKER
WORKDIR /src
RUN mkdir sharing_area
COPY ./sharing_area /src/sharing_area

# PIPENV & Prefect
WORKDIR /src/sharing_area
RUN python3.8 -m pipenv install && \
    export PATH="~/.local/bin:$PATH" && \
    pipenv run python3.8 -m pip install -U prefect && \
    pipenv run python3.8 -m pip install prefect-dask
