# https://github.com/bopen/docker-ubuntu-pyenv
FROM python:2.7.18-buster

RUN apt-get clean
RUN apt-get update --allow-releaseinfo-change
RUN apt install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        libbz2-dev \
        libffi-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        # libssl1.0-dev \
        liblzma-dev \
        libssl-dev \
        llvm \
        make \
        netbase \
        pkg-config \
        tk-dev \
        wget \
        xz-utils \
        zlib1g-dev \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

 # set the variables as per $(pyenv init -)
ENV USER="user"
ENV LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    PATH="/home/$USER/pyenv/shims:/home/$USER/pyenv/bin:$PATH" \
    PYENV_ROOT="/home/$USER/pyenv" \
    PYENV_SHELL="bash"

RUN useradd -ms /bin/bash user
USER user
WORKDIR /home/user

COPY pyenv-version.txt python-versions.txt /
RUN git clone -b `cat /pyenv-version.txt` --single-branch --depth 1 https://github.com/pyenv/pyenv.git $PYENV_ROOT \
    && for version in `cat /python-versions.txt`; do pyenv install $version; done \
    && pyenv global `cat /python-versions.txt` \
    && find $PYENV_ROOT/versions -type d '(' -name '__pycache__' -o -name 'test' -o -name 'tests' ')' -exec rm -rf '{}' + \
    && find $PYENV_ROOT/versions -type f '(' -name '*.pyo' -o -name '*.exe' ')' -exec rm -f '{}' + \
 && rm -rf /tmp/*

COPY requirements-setup.txt requirements-test.txt requirements.txt /
RUN pip install -r /requirements-setup.txt \
    && pip install -r /requirements-test.txt \
    && pip install -r /requirements.txt \
    && find $PYENV_ROOT/versions -type d '(' -name '__pycache__' -o -name 'test' -o -name 'tests' ')' -exec rm -rf '{}' + \
    && find $PYENV_ROOT/versions -type f '(' -name '*.pyo' -o -name '*.exe' ')' -exec rm -f '{}' + \
 && rm -rf /tmp/*

