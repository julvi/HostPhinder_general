FROM fedora:23
MAINTAINER Julia Villarroel, biotacg@gmail.com

RUN dnf -y update && dnf -y install wget tar python

RUN wget https://pypi.python.org/packages/source/e/ete2/ete2-2.3.10.tar.gz
RUN tar zxf ete2-2.3.10.tar.gz
RUN cd ete2-2.3.10 && python setup.py install

COPY downloadtax.py get_lineages.sh updateNCBItax.py /
