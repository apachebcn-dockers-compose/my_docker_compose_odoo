#!/bin/bash

set -e

if [ -e /home/odoo/odoo-app/addons_me/.vscode ]
then
    echo "copiando /home/odoo/odoo-app/addons_me/.vscode a /home/odoo/odoo-app (para devcontainer)"
    cp -r /home/odoo/odoo-app/addons_me/.vscode /home/odoo/odoo-app
fi


if [ "${MODE}" = "prod" ]
then
    if [ -f ${ODOO_ETC_PATH}/odoo.prod.conf ]
    then
        cp ${ODOO_ETC_PATH}/odoo.prod.conf ${ODOO_ETC_FILE}
    else
        echo ""
        echo "**************************************************************************"
        echo "No existe el fichero etc/odoo.prod.conf en el contenedor"
        echo "Comprueba que existe docker/build/etc/odoo.prod.conf"
        echo "Existe una copia de inciación en docker/build/etc/default/odoo.prod.conf"
        echo "**************************************************************************"
        echo ""
    fi
else
    if [ -f ${ODOO_ETC_PATH}/odoo.dev.conf ]
    then
        cp ${ODOO_ETC_PATH}/odoo.dev.conf ${ODOO_ETC_FILE}
    else
        echo ""
        echo "**************************************************************************"
        echo "No existe el fichero etc/odoo.dev.conf en el contenedor"
        echo "Comprueba que existe docker/build/etc/odoo.dev.conf"
        echo "Existe una copia de inciación en docker/build/etc/default/odoo.dev.conf"
        echo "**************************************************************************"
        echo ""
    fi
fi

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:='odoo-db'}
: ${PORT:=5432}
: ${USER:=${POSTGRES_USER}}
: ${PASSWORD:=${POSTGRES_PASSWORD}}

echo ""
echo "*************************************************************"
echo "CONTAINER-NAME: $CONTAINER_NAME"
echo "DB_HOST: $HOST"
echo "DB_PORT: $PORT"
echo "DB_USER: $USER"
echo "DB_PASSWORD: $PASSWORD"
echo "Using odoo conf: $ODOO_ETC_FILE"
echo "ODOO ESCUCHANDO EN PUBLIC PORT: $EXPOSE_PUBLIC_PORT_ODOO"
if [ $DEBUG_PTVSD == 1 ]
then
    echo "PTVSD ESCUCHANDO EN PUBLIC PORT: $EXPOSE_PUBLIC_PORT_DEBUG"
fi
echo "*************************************************************"
echo ""


odoobin="/home/odoo/odoo-app/odoo-bin"
if [ $DEBUG_PTVSD == 1 ]
then
    odoobin="/home/odoo/odoo-app/odoo-bin-debug"
fi


command="$odoobin $@"
if [ -f $ODOO_ETC_FILE ]
then
    command="$command --config=$ODOO_ETC_FILE"
else
    echo "$ODOO_ETC_FILE NO EXISTE!"
fi


command="$command --db_host $HOST"
command="$command --db_port $PORT"
command="$command --db_user $USER"
command="$command --db_password $PASSWORD"
echo "exec $command"
exec $command

exit 1
