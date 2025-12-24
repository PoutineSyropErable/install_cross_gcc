#!/usr/bin/env bash 
# set -euo pipefail


PYTHON_VENV_DIR="$HOME/.pip_venvs/"
send_notification() {
    $PYTHON_VENV_DIR/pip_venv/bin/python \
    /home/francois/Documents/PhoneNotification/send_notification.py \
    --title="$1" --content="$2"
}


function install_gcc32() {
		send_notification "gcc32" "Started"
	./install_gcc32.sh || {
		send_notification "gcc32" "install failed"
	}
		send_notification "gcc32" "install succeeded"
}




function install_gcc16() {
		send_notification "gcc16" "Started"
	./install_gcc16.sh || {
		send_notification "gcc16" "install failed"
	}
		send_notification "gcc16" "install succeeded"
}


function install_gcc64() {
		send_notification "gcc64" "Started"
	./install_gcc64.sh || {
		send_notification "gcc64" "install failed"
	}
		send_notification "gcc64" "install succeeded"
}


install_gcc32 
install_gcc16
install_gcc64
