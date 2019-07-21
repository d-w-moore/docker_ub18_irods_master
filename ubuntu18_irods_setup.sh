#!/bin/bash

choice="$1"

MENU=(
  build_dir_setup
  install_irods_prereqs
  compile_irods
)

if [ ! "$choice" ] ; then
  echo  -n "OPTIONS : ${MENU[*]} -> "
  read choice
fi

if [ "$choice" = build_dir_setup ]; then

  mkdir ~/github  &&  cd ~/github && \
  git clone http://github.com/irods/irods && \
  git clone http://github.com/irods/irods_client_icommands
  git clone http://bitbucket.org/dan65536/rodcycle
  cd ~/github/irods && git submodule update --init ; cd ~/github
  for x in irods*/ ; do mkdir build__$x;done

elif [ "$choice" = install_irods_prereqs ]; then

  ~/github/rodcycle/reinstall.sh -C --i=4.3.0 --w='config-essentials add-build-externals create-db'

elif [ "$choice" = compile_irods ]; then

  PATH=/opt/irods-externals/cmake3.11.4-0/bin:$PATH

  cd ~/github/build__irods && \
  echo -e '*********************************\n** building irods server and runtime **\n******************************' && \
  cmake -GNinja ../irods -DCMAKE_BUILD_TYPE=Debug && \
  ninja package && \
  ~/github/rodcycle/reinstall.sh -C --i=4.3.0 --w=basic 4

  [ $? -eq 0 ] || { echo >&2 "failed to compile."; exit 1; }

  cd ~/github/build__irods_client_icommands && \
  echo -e '************************\n** building icommands **\n************************' && \
  cmake -GNinja ../irods_client_icommands -DCMAKE_BUILD_TYPE=Debug && \
  ninja package && \
  ~/github/rodcycle/reinstall.sh -C --i=4.3.0 4 5

  [ $? -eq 0 ] || { echo >&2 "failed to compile."; exit 1; }

else

  echo >&2 "Unrecognized choice: '$choice'"

fi
