#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cp $DIR/server.cfg ~/Steam/arma/server.cfg
cp $DIR/*.pbo ~/Steam/arma/mpmissions/
