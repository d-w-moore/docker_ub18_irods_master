#!/bin/bash

choice="$1"

LOCAL_REPO=~/github
INSTALL_SCRIPT_DIR=ubuntu_irods_installer
INSTALL_SCRIPT="$LOCAL_REPO/$INSTALL_SCRIPT_DIR/install.sh"

MENU=(
  setup_build_dirs
  install_irods_prereqs
  build_irods_packages
)

if [ ! "$choice" ] ; then
  echo  -n "OPTIONS : ${MENU[*]} -> "
  read choice
elif [ "$choice" = '*' ]; then
  choice="${MENU[*]}"
fi
choice=" $choice "

if [[ "$choice" = *\ setup_build_dirs\ * ]]; then

  mkdir "$LOCAL_REPO" && cd "$LOCAL_REPO" && \
  git clone http://github.com/irods/irods && \
  git clone http://github.com/irods/irods_client_icommands
  git clone http://github.com/d-w-moore/"$INSTALL_SCRIPT_DIR"

  cd "$LOCAL_REPO"/irods && git submodule update --init ; cd "$LOCAL_REPO"
  for x in irods*/ ; do mkdir build__$x;done

elif [[ "$choice" = *\ install_irods_prereqs\ * ]]; then

  "$INSTALL_SCRIPT" -C --i=4.3.0 --w='config-essentials add-build-externals create-db'

elif [[ "$choice" = *\ build_irods_packages\ * ]]; then

  PATH=/opt/irods-externals/cmake3.11.4-0/bin:$PATH

  cd "$LOCAL_REPO"/build__irods && \
  echo -e '*********************************\n** building irods server and runtime **\n******************************' && \
  cmake -GNinja ../irods -DCMAKE_BUILD_TYPE=Debug && \
  ninja package && \
   "$INSTALL_SCRIPT" -C --i=4.3.0 --w=basic 4

  [ $? -eq 0 ] || { echo >&2 "Failed to build iRODS main packages."; exit 1; }

  cd "$LOCAL_REPO"/build__irods_client_icommands && \
  echo -e '************************\n** building icommands **\n************************' && \
  cmake -GNinja ../irods_client_icommands -DCMAKE_BUILD_TYPE=Debug && \
  ninja package && \
  "$INSTALL_SCRIPT" -C --i=4.3.0 4 5

  [ $? -eq 0 ] || { echo >&2 "failed to iRODS icommands packages."; exit 1; }

else

  echo >&2 "Unrecognized choice: '$choice'"

fi
