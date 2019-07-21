FROM ubuntu:18.04
COPY ubuntu18_irods_setup.sh / 
RUN  chmod +x /ubuntu18_irods_setup.sh
RUN  apt-get update && apt-get install -y vim tmux git tig sudo
CMD [ "/bin/bash" ]
