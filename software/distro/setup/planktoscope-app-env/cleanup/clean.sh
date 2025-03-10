#!/bin/bash -eux
# Cleanup removes unnecessary files from the operating system for a smaller and more secure disk image.

# Clean up any unnecessary apt files
sudo apt-get autoremove -y
sudo apt-get clean -y

# Clean up any unnecessary pip, poetry, and npm files
pip3 cache purge || true
POETRY_VENV=$HOME/.local/share/pypoetry/venv
BACKEND_CONTROLLER=$HOME/device-backend/control
$POETRY_VENV/bin/poetry --no-interaction --directory $BACKEND_CONTROLLER cache clear _default_cache --all
$POETRY_VENV/bin/poetry --no-interaction --directory $BACKEND_CONTROLLER cache clear piwheels --all
BACKEND_PROCESSING_SEGMENTER=$HOME/device-backend/processing/segmenter
$POETRY_VENV/bin/poetry --no-interaction --directory $BACKEND_PROCESSING_SEGMENTER cache clear _default_cache --all
$POETRY_VENV/bin/poetry --no-interaction --directory $BACKEND_PROCESSING_SEGMENTER cache clear piwheels --all

# Remove SSH keys and make them be regenerated
sudo rm -f /etc/ssh/ssh_host_*
sudo systemctl enable regenerate_ssh_host_keys.service

# Remove history files
rm -f $HOME/.bash_history
history -c && history -w
rm -f $HOME/.python_history

# Delete auto-generated keys & certs from forklift apps, for security reasons
# FIXME: we might need to stop all the containers first, because Portainer seems to automatically
# regenerate some certs after this script finishes.
sudo rm -rf /var/lib/docker/volumes/apps_*/_data/*
sudo rm -rf /var/lib/docker/volumes/infra_*/_data/*
