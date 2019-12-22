SHELL := /bin/bash

APPS = config core

requirements:
	pip install pip==18.0 --upgrade
	pip install -r .<APP NAME>/requirements.txt

requirements-freeze:
	pipenv lock --requirements > requirements.txt

requirements-install:
	pipenv install -r requirements.txt

test:
	test pipenv run base/manage.py test $(APPS)

lint:
	pipenv run flake8 --exclude */migrations/*  flake8 --ignore=E501 src
	pipenv run isort --check-only --recursive .

isort:
	pipenv run isort --recursive .

live-environment:
	pip3 install -r requirements.txt
	python3 manage.py makemigrations
	python3 manage.py migrate
	python3 manage.py collectstatic
	python3 manage.py createsuperuser

live-restart-all:
	systemctl daemon-reload
	systemctl restart gunicorn
	systemctl restart nginx

live-gunicorn-setup:
	touch /etc/systemd/system/gunicorn.service
	cat ../server_configs/gunicorn > /etc/systemd/system/gunicorn.service
	systemctl daemon-reload
	systemctl enable gunicorn
	systemctl start gunicorn
	systemctl status gunicorn

live-nginx-setup:
	touch /etc/nginx/sites-available/<APP NAME>
	cat ../server_configs/nginx > /etc/nginx/sites-available/<APP NAME>
	ln -s /etc/nginx/sites-available/<APP NAME> /etc/nginx/sites-enabled
	nginx -t

live-nginx-ufw:
	systemctl restart nginx
	ufw delete allow 8000
	ufw allow 'Nginx Full'
	ufw allow 22
	systemctl status nginx
