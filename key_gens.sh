#!/usr/bin/env bash

KeyGens() {

  new_ssh_key() {
    ssh-keygen -q -t ed25519 -N '' -f ~/.ssh/${1:-id_ed25519} <<<y >/dev/null 2>&1
  }

  nginx_self_signed_cert() {
    echo "Generating self-signed SSL certificate for local nginx..."

    local domain_name="${1:-"localhost"}"
    local ip_address="${2:-"127.0.0.1"}"

    openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes \
      -subj "/CN=$domain_name" \
      -addext "subjectAltName=IP:$ip_address" \
      -keyout /etc/ssl/private/nginx-selfsigned.key \
      -out /etc/ssl/certs/nginx-selfsigned.crt

    openssl dhparam -out /etc/ssl/certs/dhparam.pem 4096

  }

  # Calling nested functions
  local f="$1"; shift; $f $@

}
