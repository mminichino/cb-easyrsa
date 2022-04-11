#!/bin/sh

err_exit() {
  echo "$1"
  exit 1
}

if [ -z "$1" ]; then
  err_exit "Usage: $0 domain_name"
fi

DOMAIN_NAME=$1

cd easyrsa3 || err_exit "Can not change to directory easyrsa3"

./easyrsa init-pki

./easyrsa build-ca nopass

./easyrsa --subject-alt-name='DNS:*.cbos,DNS:*.cbos.cbdemo,DNS:*.cbos.cbdemo.svc,DNS:*.cbos.cbdemo.svc.cluster.local,DNS:cbos-srv,DNS:cbos-srv.cbdemo,DNS:cbos-srv.cbdemo.svc,DNS:*.cbos-srv.cbdemo.svc.cluster.local,DNS:localhost,DNS:*.'"${DOMAIN_NAME}" build-server-full couchbase-server nopass

if [ ! -d "$HOME/tls" ]; then
  mkdir $HOME/tls
fi

cp pki/ca.crt $HOME/tls/ca.crt
cp pki/private/couchbase-server.key $HOME/tls/tls.key
cp pki/issued/couchbase-server.crt $HOME/tls/tls.crt

kubectl create secret generic cbos-tls --from-file $HOME/tls/tls.crt --from-file $HOME/tls/tls.key --from-file $HOME/tls/ca.crt -n cbdemo

##