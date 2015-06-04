#! /bin/bash

PYTHONS="2.7.9"
REPOS="pypot poppy-creature poppy-ergo"

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
mkdir $HOME/dev
cd $HOME/dev

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

# Install Scipy dependancies
sudo apt-get install libblas3gf libc6 libgcc1 libgfortran3 liblapack3gf libstdc++6 build-essential gfortran python-all-dev libatlas-base-dev


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
  pip install scipy

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

