# Docker compose para Odoo (Desarrollo y Producción)

Por Pedro Reina Rojas (apachebcn@gmail.com)



## Características

Características para el entorno Docker:

- Versión de odoo seleccionable en fichero .env

- Versión de postgresql en fichero .env

- docker-compose-traefik.yml es detectado y ejecutado automáticamente vía Makefile

- PgAdmin 4 (opcional desde docker-compose)

- Cambio automático entre DEV/PROD desde comando Makefile

- docker-compose  independiente para los modos Dev/Prod

- Instalaciones adicionales desde docker/build/customs_installs/customs_installs.sh y docker/build/customs_installs/requirements.txt

- Entrada rápida a bash del contenedor Odoo y Odoo-shell (desde Makefile)

- Ptvsd activable desde fichero .env

- ~~Jupyter~~ (pendiente)

- DevContainer

  

  

## ¿Por que Odoo en Odoo?

Porque Docker nos permite una gran movilidad, simpliciad, y rapidez en el despliegue de nuestros proyectos en cualquier servidor.<br>
También nos simplifica el hacer un backup de todo el entorno, o clonarlo en cualquier lugar (Proyecto, configuración, base de datos, y todo el entorno completo)



## Presentación

Este diseño facilita la rápida conmutación entre los modos **DEV** y **PROD**, personalizando el entorno y la configuración de Odoo.<br>

El comando que se ejecuta en consola desde la raiz del proyecto,  **make dev** y **make prod**, conmutan estos 2 modos sin necesidad de recompilar la imagen.<br>
En esta conmutación automática se crean el enlace .docker-compose.yml que apunta a los ficheros docker-compose-dev.yml o docker-compose-prod.yml según el modo seleccionado.<br>
Y al mismo tiempo se genera un link, **IS-IN-MODE-DEV** o **IS-IN-MODE-PROD**, para dejar como testigo visual cual es el modo seleccionado actual.<br>

Según el modo seleccionado (con make dev o make prod), odoo usará una configuración u otra.
Siendo la variable "debug" una de las diferencias entre los 2 modos.

Ejemplo

![image-20221212144622476](readme_img/image-20221212144622476.png)



## Iniciar proyecto

### Configurar el entorno🔧

Creamos o editamos los ficheros para instalaciones adicionales:

- docker/build/customs_installs/customs_installs.sh
  - insertamos lineas de apt-get (ejemplo: apt-get install git)

- docker/build/customs_installs/requirements.txt
  - insertamos lineas de pip o pip3 install

*Estos ficheros están en .gitignore para que el repositorio no lo recoga los cambios producidos por el usuario, ya que estos determinan la configuración local del proyecto del usuario.*<br>
*Así que cuando hagamos un "git pull" a este repositorio, no habrá problemas ni conflictos por los cambios en este fichero.*



#### Entorno Docker (fichero .env)

Abrimos el fichero **docker/.env** (si no existe, lo copiamos de **docker/.env.default**)

Y lo configuramos:

```
COMPOSE_PROJECT_NAME=my-odoo
CONTAINER_NAME=my-odoo
ODOO_HOSTNAME=my_odoo.localhost

# ODOO_LOG_MODE: El nivel de log de odoo, y que por defecto va a mostrar por consola
# puede ser -> 'info', 'debug_rpc', 'warn', 'test', 'critical', 'debug_sql', 'error', 'debug', 'debug_rpc_answer', 'notset'
ODOO_LOG_MODE=error

# DEBUG_PTVSD: [0|1] Define si PTVSD va a estar a la escucha
DEBUG_PTVSD=0

# Versión de Odoo
ODOO_VERSION=14.0

# Versión de postgres
POSTGRES_VERSION=12

# Acceso a base de datos de postgres
DB_USER=odoo
DB_NAME=postgres
DB_PASSWORD=odoo

# Puertos publicos
EXPOSE_PUBLIC_PORT_ODOO=6069
EXPOSE_PUBLIC_PORT_DB=6432
EXPOSE_PUBLIC_PORT_DEBUG=3001
EXPOSE_PUBLIC_PGADMIN_PORT=4444
```



Si el fichero .env no existe, el make nos dará este error

```
Makefile:3: docker/.env: No existe el fichero o el directorio 
make: *** No hay ninguna regla para construir el objetivo 'docker/.env'.  Alto.
```



Si el link docker-compose.yml no existe, también recibiremos el mismo error
Entonces tendremos que seleccionar el modo (make dev ó make prod)

#### Preparar odoo.conf

Si es la primera vez que usamos este proyecto docker, vamos a copiar

docker/build/etc/default
a
docker/build/etc

y editamos los ficheros odoo.dev.conf  y odoo.prod.conf

Cuando docker arranca el contendor, se encarga de copiar (el modo seleccionado determina cual de los 2 ficheros copia)  al contenedor como /etc/odoo.conf

Si estos ficheros no existen, veremos en consola el siguiente error:

```
| ************************************************************************** 
| No existe el fichero etc/odoo.dev.conf en el contenedor 
| Comprueba que existe docker/build/etc/odoo.dev.conf 
| Existe una copia de inciación en docker/build/etc/default/odoo.dev.conf 
| **************************************************************************
```



#### Preparar addons_me (addons_me_default)

La carpeta volumes/addons_me_default es un referente para aplicar cosas a tu carpeta "addons_me".<br>
Copia de esta carpeta "addons_me_default" lo que te interese aplicar a "addons_me".<br>
Por defecto tenemos la carpeta ".vscode":

- **.vscode**<br>
  - Contiene
    - extensions.json: <br>La recomendación de aplicaciones a instalar. (Visual Code te ofrecerá la respectiva sugerencia)
    - launch.json:<br> 2 modos de debug:
      - Debug para el proyecto cargado como carpeta
      - Debug para el proyecto cargado como devcontainer
    - settings.json:<br>Configuración de Visual Code, entre ellos la configuración de Flake8



#### Arrancar docker con odoo configurado

Simplemente en consola, escribimos:

```
make dev
```

ó

```
make prod
```

ó si ya tienes un modo seleccionado:

```
make up
```



Nos podría aparecer el siguiente mensaje:

```
Makefile:3: docker/.env: No existe el fichero o el directorio 
make: *** No hay ninguna regla para construir el objetivo 'docker/.env'.  Alto.
```

Esto será debido a que:

- Falta el fichero **docker/.env** (tenemos una copia en docker/.env-default_env)
- Falta el link **docker/docker-compose.yml** (lo genera **make dev** o **make prod**)



Si todo va bien, veremos en consola algo así:

```
| ************************************************************* 
| CONTAINER-NAME: my-odoo
| HOST: odoo-db 
| PORT: 5432 
| USER: odoo 
| PASSWORD: odoo 
| Using odoo conf: /home/odoo/odoo-app/etc/odoo.conf 
| LISTENINT IN PUBLIC PORT: 6069 
| *************************************************************
```



Si en el navegador nos aparece:

![image-20221212173611127](readme_img/image-20221212173611127.png)

Se debe a que no hemos generado el fichero **docker/build/etc/odoo.dev.conf** o **docker/build/etc/odoo.prod.conf** (tenemos una copia de ambos en **docker/build/etc/default**)



## Comandos make

El comando make nos sirve para ahorrarnos un montón de comandos de uso frecuente.

- make start<br>
  Ejecuta docker-compose start 
- make stop<br>
  Ejecuta docker-compose stop
- make up<br>
  Ejecuta docker-compose up (adjunta automaticamente docker-compose-traefik.yml) 
- make down<br>
  Ejecuta docker-compose down 
- make up_build<br>
  Ejecuta docker-compose up --build 
- make ps<br>
  Ejecuta docker-compose ps 
- make log<br>
  Ejecuta docker-compose logs -f --tail=1000 
- make dev<br>
  Compila y arranca en modo dev 
- make prod<br>
  Compila y arranca en modo prod 
- make odoo_bash<br>
  Bash en contenedor odoo como user odoo 
- make odoo_bash_as_root<br>
  Bash en contenedor odoo como user root 
- make odoo_shell<br>
  Shell  odoo en el contenedor de odoo<br>make odoo_shell db={database} 
- make odoo_etc_show
  Ver el fichero odoo.conf 
- make odoo_update_module<br>
  Update de un módulo <br>
  make odoo_update_module db={database} module={nombre}<br>
- make odoo_update_all_modules<br>
  Update de todos los módulos de odoo<br>
  make odoo_update_module db={database}
- make odoo_scaffold:<br>
  crear nuevo módulo con toda la estructura de ficheros<br>
  odoo crear nuevo modulo db={database}
- make psql_bash<br>
  Bash en el contenedor postgresql como user postgres

- make psql_shell<br>
  Shell en el contenedor postgresql como user postgres 
- make psql_backup<br>
  Crea una copia de /volumes/db-data en formato tar.gz 
- make fix_folders_permissions<br>
  Arreglar permisos en carpetas



## Probar Odoo

Tras levantar el contenedor de docker con **make dev**/**made prod** o  **make up**<br>

Introducimos en el navegador http://locahost:6069 (o el puerto que hayamos seleccionado)<br>

Página por defecto de Odoo

![image-20221212191818352](readme_img/image-20221212191818352.png)



## Reiniciar la base de datos

1. make down (Parar la instancia del contenedor)
2. rm -R volumes/data (Borrar el contenido del volumen db-data y odoo-web-data)
3. make up (Volvemos a levantar el contenedor de docker)

Y la base de datos vuelve a crearse de nuevo.<br>



## Debug

El debug está activado por defecto en el modo "dev" y desactivado en el modo "prod"

Para cambiarlo, modificar el fichero correspondiente en **docker/build/etc**



## Debug con Ptvsd

Aplicable sólo en el modo "dev".

Para modificarlo, editar el fichero **docker/.env**:

```
DEBUG_PTVSD=True
```

Y reiniciamos el contenedor. (make down y make up)

Y en Visual Code seleccionamos el debuger que nos interesa (foto siguiente)  con el puerto especificado.<br>
Se entiende que remoteRoot (la ruta en el contenedor) es /srv/project, debiendose cambiar si tu proyecto en el contenedor difiere de esta ruta.

![image-20221212201310435](readme_img/image-20221212201310435.png)

Acto seguido y como es popularmente sabido, marcamos los puntos de interrupción en los ficheros, y hacemos click en el icono "play" del debug.



## Jupyter (pendiente)



## Visual Code

Hay 2 formas de abrir el código de Odoo 

### Abrir el proyecto como carpeta.

Abrimos con Visual Code la carpeta volumes/addons_me.<br>
Desde esta carpeta programaremos sobre nuestros módulos.<br>
Y sobre esta carpeta Visual Code leerá la carpeta .vscode, donde aplicará, configuraciones, configuración del debug, recomendaciones sobre una lista predefinida de complementos de Visual Code.<br>
(si la carpeta .vscode no existe, encontraremos un ejemplar en volumes/django_default)



### Abrir el proyecto como Devcontainer

Para poder usar Devcontainer, es necesario instalar previamente el complemento: **ms-vscode-remote.remote-containers**<br>

El constructor del contenedor copia el volumes/addons_me/.vscode al entorno Devcontainer.<br>
Recuerda  **volumes/addons_me/.vscode => /home/odoo/odoo_app/.vscode (Devcontainer)**<br>
y .devcontainer/devcontainer.json también tiene su propio settings, siendo el resultado final la mezcla de ambos.

Para abrir el proyecto con Devcontainer hay 3 formas de hacer:

- #### Desde visual code

  Abrimos con Visual Code la carpeta raíz del proyecto (justo el nivel superior donde se encuentra la carpeta **.devcontainer**) .<br>Nos tiene que aparece el siguiente diálogo el cual haremos click en "Reopen in Container"
  ![image-20221212200347030](readme_img/image-20221212200347030.png)

- #### Desde el navegador de ficheros

  Con el típico abrir con... y abriendo la carpeta raíz del proyecto.<br>
  Y mismo caso que antes
  ![image-20221212200347030](readme_img/image-20221212200347030.png)

- #### Desde visual code y el complemento Devcontainer

  Previamente levantamos el contendor (make up)<br>
  Abrimos Visual Code<br>
  Presionamos Ctrl+Shift+P (o F1) y escribimos "devcontainer"

  ![image-20221212205332924](readme_img/image-20221212205332924.png)

  Seleccionamos "Attach to Running Container"
  A continuación se abre una lista con los contenedores que están funcionando en el sistema, y seleccionamos el servicio que corresponde a nuestro contenedor.

Haciendo esto, estaremos abriendo con Visual Code un entorno especial donde encontraremos, todos los ficheros del contenedor a disposición del IDE como si se tratasen de ficheros locales, debug, complementos, configuraciones varias.<br>

Devcontainer es una nueva tecnología de Visual Studio Code que ofrece este modo de trabajo tan interesante.<br>

Para el conocimiento de Devcontainer => https://code.visualstudio.com/docs/devcontainers/containers<br>

El devcontainer configurado en este proyecto es muy básico y simplificado, que nada tiene que ver con las posibilidades que ofrece esta tecnología.<br>

Ejemplo de Devcontainer cargado:

![image-20221212235140186](readme_img/image-20221212235140186.png)

### Como funciona internamente Devcontainer

Cuando Visual Studio Code se abre en modo 'devcontainer', hace lo siguiente<br>

- Se conecta al contenedor de Odoo, y la gestion de ficheros y la terminal se ejecuta desde dentro del contenedor, ofreciéndonos los recursos del mismo como si estuviesen en local.<br>
  De hecho, si hacemos un "abrir fichero", no podremos abrir ficheros locales, las rutas mostradas son las del contenedor.
- El devcontainer aplica a nuestro Visual Studio Code las configuraciones visuales y funcionales indicadas en el fichero devcontainer.json
- El devcontainer va a instalar todas las extensiones a nuestro Visual Studio Code (ojo, no son recomendaciones como en un extensions.json, serán instalaciones explicitas)

En conjunto, devcontainer nos ofrece un entorno completo tal como se define en devcontainer.json.<br>

Y el resultado final es como si alguien te estuviese prestando su entorno de trabajo, tal como lo está usando en su día a día.
