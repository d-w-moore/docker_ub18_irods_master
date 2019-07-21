#!/bin/bash

if [ "$1" = setup ]; then

  mkdir ~/github  &&  cd ~/github && \
  git clone http://github.com/irods/irods && \
  git clone http://github.com/irods/irods_client_icommands
  git clone http://bitbucket.org/dan65536/rodcycle
  cd ~/github/irods && git submodule update --init ; cd ~/github
  for x in irods*/ ; do mkdir build__$x;done

  ~/github/rodcycle/reinstall.sh -C --i=4.3.0 --w='config-essentials add-build-externals create-db'

elif [ "$1" = compile ]; then

  cd ~/github
  PATH=/opt/irods-externals/cmake3.11.4-0/bin:$PATH
  cmake -GNinja ../irods -DCMAKE_BUILD_TYPE=Debug
  ninja package
  ~/github/rodcycle/reinstall.sh -C --i=4.3.0  --w=basic 4
  cd ../build*cli*
  cmake -GNinja ../irods_client_icommands -DCMAKE_BUILD_TYPE=Debug
  ninja package
  ~/github/rodcycle/reinstall.sh -C --i=4.3.0   4 5

else

  echo >&2 "unrecognized subcommand '$1'"

fi
