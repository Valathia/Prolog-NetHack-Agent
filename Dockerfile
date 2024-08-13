
################################################################################
## SUS(Ana) no labirinto da nethack
################################################################################
# docker build . -t prolog && docker run prolog
# docker build . -t prolog && docker run -it -e DISPLAY="${IP}:0" -v /tmp/.X11-unix:/tmp/.X11-unix prolog
################################################################################
## Miguel Madureira, o desenmerdador
################################################################################
FROM --platform=linux/amd64 ubuntu:jammy
RUN apt update 
RUN apt install software-properties-common -y
RUN add-apt-repository ppa:swi-prolog/stable 
RUN apt update 
RUN DEBIAN_FRONTEND=noninteractive apt upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt install ca-certificates \
    swi-prolog \
    wget \
    python3-pip \
    python3-dev \
    python3-numpy \
    git \
    flex \
    bison \
    libbz2-dev \
    cmake \
    build-essential \
    autoconf \
    libtool \
    pkg-config \
    ncurses-term \
    -y
# Install pygame
RUN pip install pygame
RUN pip install janus_swi
# Install spacy and its dependencies
RUN pip install spacy 
RUN python3 -m spacy download en_core_web_sm
# Install nle and its dependencies
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add -
RUN add-apt-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
RUN DEBIAN_FRONTEND=noninteractive apt --allow-unauthenticated install -y \
    kitware-archive-keyring
RUN pip3 install nle
RUN apt-get install -y x11-apps
# Create an environment for our app
WORKDIR /app
# Get codes file
COPY ./codes.pl .
# Get protocols file
COPY ./protocols.pl .
# Get actions file
COPY ./actions.pl .
# Get game_run file
COPY ./game_run.pl .
# Get GUI 
COPY ./prolog_gui.py .
# Get Assets DIR with all it's contents
COPY ./assets ./assets
# Get Main prolog file
COPY ./main.pl .
# Get interface between prolog and GUI file
COPY ./interface.py .
# Get Spritesheet file
COPY ./spritesheet.py .
#ENV PYTHONPATH="${PYTHONPATH}:."
# start program from interface.py
CMD ["python3","interface.py"]
#CMD ["swipl", "-q", "-l", "main.pl"]