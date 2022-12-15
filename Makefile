SHELL := /bin/bash

include ./docker/.env

help: ## Ayudita.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

__delete_links:
	@cd docker && sudo rm -f docker-compose.yml && cd .. && sudo rm -f ./IS-IN-MODE-*

__set_dev_links:
	@cd docker && sudo ln -s docker-compose-dev.yml docker-compose.yml && cd .. && sudo touch IS-IN-MODE-DEV

__set_prod_links:
	@cd docker && sudo ln -s docker-compose-prod.yml docker-compose.yml && cd .. && sudo touch IS-IN-MODE-PROD

dev: ## cambia los links a modo dev
dev: __delete_links __set_dev_links

prod: ## cambia los links a modo prod
prod: __delete_links __set_prod_links

start: ## docker-compose start
	@cd docker && docker-compose start

stop: ## docker-compose stop
	@cd docker && docker-compose stop

up: ## docker-compose up (with docker-compose-traefik.yml)
	@cd docker && [ -f docker-compose-traefik.yml ] && docker-compose -f docker-compose.yml -f docker-compose-traefik.yml up || docker-compose up

up_build: ## docker-compose up --build
	@cd docker && docker-compose build
	@cd docker && [ -f docker-compose-traefik.yml ] docker-compose -f docker-compose.yml -f docker-compose-traefik.yml up || docker-compose up

down: ## docker-compose down
	@cd docker && docker-compose down > /dev/null

log: ## docker-compose logs -f --tail=1000
	@cd docker && docker-compose logs -f --tail=1000

ps: ## docker-compose ps
	@cd docker && docker-compose ps

odoo_bash: ## Bash en contenedor odoo
	@docker exec -u odoo -ti ${CONTAINER_NAME} bash

odoo_bash_root: ## Bash en contenedor odoo as root user
	@docker exec -u root -ti ${CONTAINER_NAME} bash

odoo_shell: ## odoo shell. SINTAXIS: make odoo_shell db={database}
	@if [ -v db ]; then docker exec -u root -ti ${CONTAINER_NAME} /home/odoo/odoo-app/odoo-bin shell -d ${db} -c /home/odoo/odoo-app/etc/odoo.conf --http-port=83; fi

odoo_etc_show: ## Mostrar odoo.conf desde el contenedor de odoo
	@docker exec -u root -ti ${CONTAINER_NAME} cat /home/odoo/odoo-app/etc/odoo.conf

odoo_update_module: ## odoo actualizar 1 modulo. SINTAXIS: make odoo_update_module db={database} module={nombre}
	@if [ -v db ]; then docker exec -u root -ti ${CONTAINER_NAME} /home/odoo/odoo-app/odoo-bin -d ${db} -c /home/odoo/odoo-app/etc/odoo.conf --http-port=83 -u $(module); fi

odoo_update_all_modules: ## odoo actualizar todos los módulos. SINTAXIS: make odoo_update_module db={database}
	@if [ -v db ]; then docker exec -u root -ti ${CONTAINER_NAME} /home/odoo/odoo-app/odoo-bin -u all -d ${db} -c /home/odoo/odoo-app/etc/odoo.conf --http-port=83; fi

odoo_scaffold: ## odoo crear nuevo modulo. SINTAXIS: make odoo_scaffold modulo={modulo}
	@if [ -v modulo ]; then docker exec -u odoo -ti ${CONTAINER_NAME} /home/odoo/odoo-app/odoo-bin scaffold /home/odoo/odoo-app/addons_me/${modulo}; fi

psql_bash: ## Bash en contenedor mysql
	@docker exec -u postgres -ti ${CONTAINER_NAME}_db bash

psql_shell: ## Bash en contenedor postgresql como user postgres
	@docker exec -u postgres -ti ${CONTAINER_NAME}_db psql

psql_backup: ## Backup de mysql
	@sudo tar cvfz ./db.tar.gz ./volumes/db-data

fix_folders_permissions: ## Arreglar permisos en carpetas
	@sudo chmod -R 777 ./volumes/data/odoo-web-data
