#!/bin/bash
# Pfad an dein tatsächlich eingebundenes Data Drive anpassen:
DATA_DRIVE=/data bash install-strata.sh

cd /data/ai/Strata-DGX-Spark
./run-coder-iq1_m.sh