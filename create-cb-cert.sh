#!/bin/sh

err_exit() {
  echo "$1"
  exit 1
}

if [ -z "$1" -o -z "$2" ]; then
  err_exit "Usage: $0 domain_name namespace"
fi

DOMAIN_NAME=$1
NAMESPACE=$2

cd easyrsa3 || err_exit "Can not change to directory easyrsa3"

./easyrsa init-pki

./easyrsa build-ca nopass

./easyrsa --subject-alt-name='DNS:*.cbos,DNS:*.cbos.'"${NAMESPACE}"',DNS:*.cbos.'"${NAMESPACE}"'.svc,DNS:*.cbos.'"${NAMESPACE}"'.svc.cluster.local,DNS:cbos-srv,DNS:cbos-srv.'"${NAMESPACE}"',DNS:cbos-srv.'"${NAMESPACE}"'.svc,DNS:*.cbos-srv.'"${NAMESPACE}"'.svc.cluster.local,DNS:localhost,DNS:*.'"${DOMAIN_NAME}" build-server-full couchbase-server nopass

if [ ! -d "$HOME/tls" ]; then
  mkdir $HOME/tls
fi

cp pki/ca.crt $HOME/tls/ca.crt
cp pki/private/couchbase-server.key $HOME/tls/tls.key
cp pki/issued/couchbase-server.crt $HOME/tls/tls.crt

kubectl create secret generic cbos-tls --from-file $HOME/tls/tls.crt --from-file $HOME/tls/tls.key --from-file $HOME/tls/ca.crt -n cbdemo

##