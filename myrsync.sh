#!/bin/bash
rsync -avz --delete-after --log-file=/tmp/rsync-log /opt/envato mbs@threnody:/opt/envato
rsync -avz --delete-after --log-file=/tmp/rsync-log /opt/packages mbs@threnody:/opt/packages
