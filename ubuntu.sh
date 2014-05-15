#! /bin/bash

sed -i 's/us\./gb./g' /etc/apt/sources.list

wget --no-check-certificate -c https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
wget -c http://www.rabbitmq.com/releases/rabbitmq-server/v3.2.4/rabbitmq-server_3.2.4-1_all.deb
sudo dpkg -i erlang-solutions_1.0_all.deb
apt-get update
apt-get install -y erlang-nox
sudo dpkg -i rabbitmq-server_3.2.4-1_all.deb
sudo apt-get install -y vim

sudo /etc/init.d/rabbitmq-server stop

echo "deadbeefcafecoffeebabefeed" > /var/lib/rabbitmq/.erlang.cookie
chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie
chmod 600 /var/lib/rabbitmq/.erlang.cookie

rabbitmq-plugins enable rabbitmq_management

cat >> /etc/hosts <<HOSTS
192.168.56.211 rabbit1
192.168.56.212 rabbit2
192.168.56.213 rabbit3
HOSTS

cat >> /etc/rabbitmq/rabbitmq.config <<CONFIG
[
  {rabbit,
    [
      {cluster_nodes, {['rabbit@rabbit1', 'rabbit@rabbit2', 'rabbit@rabbit3'], disc}},
      {cluster_partition_handling, pause_minority}
    ]
}].
CONFIG

sudo /etc/init.d/rabbitmq-server start -detached
sleep 10
sudo rabbitmqctl stop_app
sudo rabbitmqctl reset
sudo rabbitmqctl stop
sudo /etc/init.d/rabbitmq-server start -detached
