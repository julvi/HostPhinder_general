#!/bin/bash

docker run -ti --rm \
--volume /dat1/taxonomy/input:/input \
--volume /dat1/taxonomy/output:/output \
tax \
bash

