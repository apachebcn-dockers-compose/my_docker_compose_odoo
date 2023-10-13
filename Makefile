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

up: ## docker-compose up
	@cd docker && docker-compose -f docker-compose.yml up -d

up_build: ## docker-compose up --build
	@cd docker && docker-compose build
	@cd docker && docker-compose -f docker-compose.yml up

down: ## docker-compose down
	@cd docker && docker-compose down > /dev/null

log: ## docker-compose logs -f --tail=1000
	@cd docker && docker-compose logs -f --tail=1000

ps: ## docker-compose ps
	@cd docker && docker-compose ps

fix_folders_permissions: ## Arreglar permisos en carpetas
	@sudo chmod -R 777 ./volumes/data/odoo-web-data
	@docker exec -u root -ti ${CONTAINER_NAME} chown -R odoo:odoo /home/odoo/odoo-web-data

config_show: ## Mostrar configuración. fichero '.env'(Docker) y fichero 'odoo.conf'(Contenedor)
	@echo ""
	@echo "*************************************************************"
	@echo "* CONFIG IN Docker enf file"
	@cat ./docker/.env
	@echo ""
	@echo "*************************************************************"
	@echo "* CONFIG IN CONTAINER /home/odoo/odoo-app/etc/odoo.conf"
	@echo "* Si quieres realizar cambios en /home/odoo/odoo-app/etc/odoo.conf debes hacerlo en build/etc/odoo.dev.conf y odoo.prod.conf y hacer ejecutar 'make up_build'"
	@docker exec -u root -ti ${CONTAINER_NAME} cat /home/odoo/odoo-app/etc/odoo.conf
	@echo "*************************************************************"
	@echo ""

config_reset: ## Resetear configuración. fichero '.env'(Docker) y fichero 'odoo.conf'(Contenedor)
	@cp ./docker/build/etc/default/odoo.dev.conf ./docker/build/etc/odoo.dev.conf
	@cp ./docker/build/etc/default/odoo.prod.conf ./docker/build/etc/odoo.prod.conf
	@cp ./docker/.env-default ./docker/.env

config_remove: ## Eliminar configuración. fichero '.env'(Docker) y fichero 'odoo.conf'(Contenedor)
	@rm ./docker/build/etc/odoo.dev.conf
	@rm ./docker/build/etc/odoo.prod.conf
	@rm ./docker/.env

volume_dbs_backup: ## Backup del contenido de la carpeta postgresql
	@sudo tar cvfz ./db.tar.gz ./volumes/data
	@sudo chmod 777 ./db.tar.gz

container_odoo_bash: ## Bash en contenedor odoo
	@docker exec -u odoo -ti ${CONTAINER_NAME} bash

container_odoo_bash_root: ## Bash en contenedor odoo as root user
	@docker exec -u root -ti ${CONTAINER_NAME} bash

container_odoo_shell: ## Entrar en el shell de odoo(Container como user odoo). SINTAXIS: make container_odoo_shell db={database}
	@if [ -v db ]; then docker exec -u odoo -ti ${CONTAINER_NAME} /home/odoo/odoo-app/odoo-bin shell -d ${db} ; else echo "Te falta indicar algunos argumentos necesarios"; fi

container_odoo_update_module: ## odoo actualizar 1 modulo. SINTAXIS: make container_odoo_update_module db={database} module={nombre}
	@if [ -v db ]; then docker exec -u root -ti ${CONTAINER_NAME} /home/odoo/odoo-app/odoo-bin -d ${db} -c /home/odoo/odoo-app/etc/odoo.conf --http-port=83 -u $(module); else echo "Te falta indicar algunos argumentos necesarios"; fi

container_odoo_update_all_modules: ## odoo actualizar todos los módulos. SINTAXIS: make container_odoo_update_module db={database}
	@if [ -v db ]; then docker exec -u root -ti ${CONTAINER_NAME} /home/odoo/odoo-app/odoo-bin -u all -d ${db} -c /home/odoo/odoo-app/etc/odoo.conf --http-port=83; else echo "Te falta indicar algunos argumentos necesarios"; fi

container_odoo_scaffold: ## odoo crear nuevo modulo. SINTAXIS: make container_odoo_scaffold modulo={modulo}
	@if [ -v modulo ]; then docker exec -u odoo -ti ${CONTAINER_NAME} /home/odoo/odoo-app/odoo-bin scaffold /home/odoo/odoo-app/addons_me/${modulo}; else echo "Te falta indicar algunos argumentos necesarios"; fi

container_psql_bash: ## Bash del contenedor postgresql
	@docker exec -u postgres -ti ${CONTAINER_NAME}-db bash

container_psql_shell: ## Entrar en el shell postgresql (Container como user postgres)
	@docker exec -u postgres -ti ${CONTAINER_NAME}-db psql -h 'localhost' --username '${DB_USER}' password '${DB_PASSWORD}'

container_psql_db_create: ## Crea base de datos en psql. SINTAXIS:  make container_psql_db_create db={database}
	@if [ -v db ]; then docker exec -it ${CONTAINER_NAME}-db createdb -U ${DB_USER} -h localhost -p 5432 -E UTF8 -T template0 --lc-collate=en_US.UTF-8 --lc-ctype=en_US.UTF-8 -O ${DB_USER} ${db}; else echo "Te falta indicar algunos argumentos necesarios"; fi

container_psql_db_remove: ## Elimina base de datos en psql. SINTAXIS:  make container_psql_db_remove db={database}
	@if [ -v db ]; then docker exec -it ${CONTAINER_NAME}-db dropdb -U ${DB_USER} -h localhost -p 5432 ${db}; else echo "Te falta indicar algunos argumentos necesarios"; fi

container_psql_import: ## Importa fichero /volumes/data/db-data/import_dump.sql a la base de datos {db} de postgresql. SINTAXIS:  make container_psql_import db={database}
	@if [ -v db ]; then docker exec -u postgres -ti ${CONTAINER_NAME}-db psql --username=${DB_USER} password={DB_PASSWORD} --dbname=${db} -f /var/lib/postgresql/data/pgdata/import_dump.sql; else echo "Te falta indicar algunos argumentos necesarios"; fi

container_psql_export: ## Exporta base de datos {db} de postgresql a fichero /volumes/data/db-data/export_dump.sql. SINTAXIS:  make container_psql_import db={database}
	@if [ -v db ]; then docker exec -u postgres ${CONTAINER_NAME}-db pg_dump --username=${DB_USER} --dbname=${db} --file=/var/lib/postgresql/data/pgdata/export_dump.sql; else echo "Te falta indicar algunos argumentos necesarios"; fi
