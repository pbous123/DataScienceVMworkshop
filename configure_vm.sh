#!/bin/bash

source /etc/profile
conda activate py36

pip install azureml-core
pip install azureml-accel-models[cpu] --user

# enable the widgets 
wget https://dsvmassets.blob.core.windows.net/mladsfall2018/azureml_train_widgets.tar.gz -O /tmp/azureml_train_widgets.tar.gz
tar xzf /tmp/azureml_train_widgets.tar.gz -C /usr/local/share/jupyter/nbextensions

mkdir -p /etc/skel/.jupyter/nbconfig
echo '{ "load_extensions": { "azureml_train_widgets/extension": true } }' | tee /etc/skel/.jupyter/nbconfig/notebook.json

# install h5py for Keras
conda install h5py -y

# download the notebooks
mkdir /etc/skel/notebooks/MLADS-fall-2018
git clone https://github.com/Azure/DataScienceVM /data/DataScienceVM
mv /data/DataScienceVM/Tutorials/MLADS-fall-2018/* /etc/skel/notebooks/MLADS-fall-2018

# copy the notebooks to the initial user's profile
for filename in /home/*; do
  dir=$filename/notebooks
  user=${filename:6}
  cp -r /etc/skel/notebooks/MLADS-fall-2018 $dir
  chown -R $user $dir/MLADS-fall-2018/*
  chown $user $dir/MLADS-fall-2018
done

host=`hostname`
# create users
# we are skipping this part now that MLADS is over, and most people using this template want
# to use it with the initial user account
for i in $(seq 1 10);  do
  u=`openssl rand -hex 2`;
  # replace 1 with g
  u=`echo $u | sed -e 's/1/g/g'`
  # replace 0 with h
  u=`echo $u | sed -e 's/0/h/g'`

  p=`openssl rand -hex 4`;
  # replace 1 with g
  p=`echo $p | sed -e 's/1/g/g'`
  # replace 0 with h
  p=`echo $p | sed -e 's/0/h/g'`

 useradd -m -d /home/user$u -s /bin/bash user$u
  echo user$u:$p | chpasswd
  echo $host, user$u, $p >> '/data/usersinfo.csv';
  usermod -aG docker user$u
 done
