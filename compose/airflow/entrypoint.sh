#!/usr/bin/env bash

export AIRFLOW__CORE__FERNET_KEY=$(python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")
export AIRFLOW__CORE__LOAD_EXAMPLES=False

# This script checks the permissions on /var/run/docker.sock 
#     (which is mounted into the container by the host) and ensures that
#     the user under which Airflow is running has the appropriate permissions to communicate over the socket.

AIRFLOW_USER='airflow'
DOCKER_GROUP=`ls -al /var/run/docker.sock  | awk '{print $4}'`

if ! id -nG "$AIRFLOW_USER" | grep -qw "$DOCKER_GROUP"; then
	adduser $AIRFLOW_USER $DOCKER_GROUP
fi

# Install custom python package if requirements.txt is present
if [ -e "/requirements.txt" ]; then
    $(command -v pip) install --user -r /requirements.txt
fi

case "$1" in
  webserver)
    airflow initdb
    airflow scheduler &
    exec airflow webserver
    ;;
  version)
    exec airflow "$@"
    ;;
  *)
    # The command is something like bash, not an airflow subcommand. Just run it in the right environment.
    exec "$@"
    ;;
esac