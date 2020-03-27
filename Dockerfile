FROM continuumio/anaconda3:2019.07

RUN /opt/conda/bin/conda update -y conda
RUN mkdir /vampire
COPY Dockerfile /vampire/
COPY install/ /vampire/install/
WORKDIR /vampire
# Install conda dependencies.
RUN /opt/conda/bin/conda env create -f install/environment.yml
RUN export LC_ALL=C.UTF-8
RUN export LANG=C.UTF-8
RUN apt-get update && apt-get install -y procps && apt-get install nano
