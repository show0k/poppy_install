#! /bin/bash

PYTHONS="2.7.9"
REPOS="pypot poppy-creature poppy-ergo"

if [ `whoami` != "root" ];
then
	echo "You must run the app as root:"
	echo "sudo bash $0"
	exit 0
fi

# Update needed apps.
echo 'Update your system.'
apt-get clean
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get -y install  axel wget unzip whiptail python-pip python-opencv guvcview \
                    xz-utils libportaudio0 libportaudio2 libportaudiocpp0 \
                    portaudio19-dev python-setuptools libnss-mdns curl git i2c-tools \
                    make build-essential libssl-dev zlib1g-dev libbz2-dev \
                    libreadline-dev libsqlite3-dev wget llvm python-pyaudio

# Install pyenv
export PATH="$HOME/.pyenv/bin:$PATH"

if hash pyenv 2>/dev/null; then
  echo pyenv already installed.
else
  curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

  echo "
export PATH=\"\$HOME/.pyenv/bin:\$PATH\"
eval \"\$(pyenv init -)\"
eval \"\$(pyenv virtualenv-init -)\"
" >> ~/.bashrc

  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

# Clone repos
echo 'Clone repos.'
mkdir /home/poppy/dev
cd /home/poppy/dev

# Clone poppy repos.
for repo in $REPOS
do
  if [[ $repo == poppy-ergo ]]; then
    username=pierre-rouanet
  else
    username=poppy-project
  fi

  path=https://github.com/$username/$repo.git
  git clone $path
done

# Install Poppy repos
for PYTHON in $PYTHONS
do
  pyenv install $PYTHON
  pyenv rehash
  pyenv global $PYTHON

  pip install ipython[all]

  if [[ $PYTHON == pypy* ]]; then
    numpy_repo=git+https://bitbucket.org/pypy/numpy.git
  else
    numpy_repo=numpy
  fi

  pip install $numpy_repo

  for repo in $REPOS
  do
    path=~/dev/$repo

    if [[ $repo == poppy-* ]]; then
      path=$path/software
    fi

    cd $path
    python setup.py develop
  done
done

