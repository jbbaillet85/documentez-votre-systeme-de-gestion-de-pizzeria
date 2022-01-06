#!/bin/bash

sudo apt update
sudo apt install python3-pip python3-dev libpq-dev postgresql postgresql-contrib nginx curl

sudo -H pip3 install --upgrade pip
sudo -H pip3 install virtualenv

mkdir ~/ocpizzas
cd ~/ocpizzas

virtualenv .venv
source .venv/bin/activate
pip install django gunicorn psycopg2-binary

echo ~/ocpizzas/ocpizzas/settings.py

~/ocpizzas/manage.py makemigrations
~/ocpizzas/manage.py migrate

echo "from django.contrib.auth import get_user_model; User = get_user_model(); 
User.objects.create_superuser('OCpizzaUser', 'OCpizzaUser@mail.com', 'ocPizza!')" | python ~/ocpizzas/manage.py shell

~/ocpizzas/manage.py collectstatic

cd ~/ocpizzas
gunicorn --bind 0.0.0.0:8000 ocpizzas.wsgi

deactivate

sudo echo "
[Unit]
Description=gunicorn socket

[Socket]
ListenStream=/run/gunicorn.sock

[Install]
WantedBy=sockets.target" >> /etc/systemd/system/gunicorn.socket

sudo echo "
[Unit]
Description=gunicorn daemon
Requires=gunicorn.socket
After=network.target

[Service]
User=OCpizzaUser
Group=www-data
WorkingDirectory=/home/OCpizzaUser/myprojectdir
ExecStart=/home/OCpizzaUser/ocpizzas/.venv/bin/gunicorn \
          --access-logfile - \
          --workers 3 \
          --bind unix:/run/gunicorn.sock \
          ocpizzas.wsgi:application

[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/gunicorn.service

sudo systemctl start gunicorn.socket
sudo systemctl enable gunicorn.socket

sudo echo "
server {
    listen 80;
    server_name server_domain_or_IP;

    location = /favicon.ico { access_log off; log_not_found off; }
    location /static/ {
        root /home/sammy/myprojectdir;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:/run/gunicorn.sock;
    }
}" >> /etc/nginx/sites-available/ocpizzas

sudo ln -s /etc/nginx/sites-available/ocpizzas /etc/nginx/sites-enabled
sudo systemctl restart nginx
