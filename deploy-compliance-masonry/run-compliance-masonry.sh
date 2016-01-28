#!/bin/bash
pip install git+https://github.com/opencontrol/compliance-masonry.git
cd compliance-repository
masonry certs LATO
masonry docs gitbook LATO
exit 0
