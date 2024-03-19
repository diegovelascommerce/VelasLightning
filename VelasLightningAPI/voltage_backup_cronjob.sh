#!/bin/bash 
# run `crontab -e` and add the following line to the file 
# 0 0 * * * /Users/diegovila/Velas/WORKIT_iOS_Dev/VelasLightning/VelasLightningAPI/voltage_backup_cronjob.sh

PIPENV=/Users/diegovila/.pyenv/shims/pipenv 
SCRIPT=/Users/diegovila/Velas/WORKIT_iOS_Dev/VelasLightning/VelasLightningAPI/voltage_backup.py

eval "$PIPENV run python $SCRIPT"
