FROM python:3.7
LABEL org.opencontainers.image.authors="apachebcn@gmail.com"

#####################################################
#
# CREADO POR PEDRO REINA ROJAS (apachebcn@gmail.com)
#
#####################################################

#####################################################
#
# Para adicionar con apt-get, hacerlo en los ficheros:
#    - docker/build/install_customs.sh
#    - docker/build/requirements.txt
#
#####################################################



ENV ODOO_USER_HOME "/home/odoo"
ENV ODOO_APP_PATH "/home/odoo/odoo-app"
ENV ODOO_ETC_PATH "/home/odoo/odoo-app/etc"
ENV ODOO_ETC_FILE "/home/odoo/odoo-app/etc/odoo.conf"


########
# SISTEMA OPERATIVO
#
########
RUN set -x; apt-get update
RUN set -x; apt-get install -y \
    build-essential\
    ca-certificates \
    curl \
    git \
    libxml2-dev \
    libsasl2-dev \
    python3 \
    libldap2-dev \
    libxmlsec1-dev \
    libssl-dev \
    locales \
    locales-all \
    mc \
    nodejs \
    node-less \
    postgresql-client \
    zip \
    unzip \
    wget \
    xz-utils


########
# DEPENDENCIAS COMUNES DE ODOO
#
########
RUN pip3 install --upgrade pip
RUN pip3 install psycopg2-binary
RUN pip3 install openupgradelib
RUN pip3 install unidecode
RUN pip3 install num2words
RUN pip3 install numpy
RUN pip3 install netifaces
RUN pip3 install paramiko
RUN pip3 install phonenumbers
RUN pip3 install pyldap
RUN pip3 install pyOpenSSL
RUN pip3 install qrcode
RUN pip3 install vobject
RUN pip3 install xlrd
RUN pip3 install openpyxl
RUN pip3 install xlwt
RUN pip3 install xmlsig
RUN pip3 install zeep
RUN pip3 install simplejson
RUN pip3 install PyPDF2
RUN pip3 install passlib
RUN pip3 install babel
RUN pip3 install decorator
RUN pip3 install psycopg2-binary
RUN pip3 install Pillow
RUN pip3 install psutil
RUN pip3 install reportlab
RUN pip3 install html2text
RUN pip3 install docutils
RUN pip3 install suds
RUN pip3 install inotify
RUN pip3 install python-stdnum==1.8
RUN pip3 install vatnumber
RUN pip3 install Jinja2==2.10.1
RUN pip3 install MarkupSafe==0.23
RUN pip3 install werkzeug==0.16.0
RUN pip3 install ptvsd
# RUN pip3 install ptvsd==4.1.1a10  ptvsd alternativo si falla el normal, pero es mucho más lento


########
# INSTALL CUSTOMS
#
########
COPY customs_installs ${ODOO_APP_PATH}/customs_installs
RUN if test -e ${ODOO_APP_PATH}/customs_installs/customs_installs.sh; then chmod +x ${ODOO_APP_PATH}/customs_installs/customs_installs.sh ; fi
RUN if test -e ${ODOO_APP_PATH}/customs_installs/requirements.txt; then pip3 install -r ${ODOO_APP_PATH}/customs_installs/requirements.txt ; fi


########
# INSTALAR wkhtmltox
#
########
RUN set -x; curl -o wkhtmltox.deb -SL https:/github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
    && echo '7e35a63f9db14f93ec7feeb0fce76b30c08f2057 wkhtmltox.deb' | sha1sum -c - \
    && dpkg --force-depends -i wkhtmltox.deb\
    && apt-get -y install -f --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb


########
# LOCALES
#
########
# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG es_ES.UTF-8
ENV locale-gen es_ES.UTF-8
ENV LANGUAGE es_ES:es
ENV LC_ALL es_ES.UTF-8
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime
RUN export LANGUAGE=es_ES.UTF-8
RUN export LANG=es_ES.UTF-8
RUN export LC_ALL=es_ES.UTF-8
RUN locale-gen es_ES.UTF-8
RUN dpkg-reconfigure locales


########
# CREAR USER ODOO
#
########
RUN useradd --create-home --home-dir ${ODOO_USER_HOME} --no-log-init odoo
RUN chown -R odoo:odoo ${ODOO_USER_HOME}
RUN echo "odoo:odoo" | chpasswd


########
# PREPARAR DIRECTORIOS
#
########
RUN mkdir -p "${ODOO_USER_HOME}/odoo-web-data"
RUN mkdir -p /var/lib/odoo
RUN mkdir -p /var/lib/odoo/sessions
RUN chown -R odoo:odoo /var/lib/odoo


########
# ENTRAR COMO USUARIO ODOO
#
########
USER odoo


########
# INSTALAR ODOO
#
########
RUN rm -R ${ODOO_APP_PATH}
ARG ODOO_VERSION
RUN git clone --depth=1 https://github.com/odoo/odoo.git -b ${ODOO_VERSION} ${ODOO_APP_PATH} && rm -rf .git && rm -rf .github
RUN pip3 install --upgrade pip
RUN pip3 install -r /home/odoo/odoo-app/requirements.txt

# COPIAR DIRECTORIOS DE ADDONS
COPY container_volumes ${ODOO_APP_PATH}

# COPIAR odoo.conf AL CONTENEDOR Y SETEARLO EN EL ENTORNO DE ODOO
RUN mkdir -p ${ODOO_ETC_PATH}
ADD ./etc ${ODOO_ETC_PATH}

# COPIAR FICHERO odoo-bin-debug
COPY ./odoo-bin-debug.py ${ODOO_APP_PATH}/odoo-bin-debug

# COPIAR CARPETA volumes/addons_me/.vscode a /home/odoo/odoo-app (para que lo lea devcontainer)
# RUN if test -d ../../volumes/addons_me/.vscode; then COPY ../../volumes/addons_me/.vscode ${ODOO_APP_PATH}/.vscode ; fi

# COPY /devcontainer/devcontainer.json /${ODOO_APP_PATH}/.vscode

########
# SALIR DE USUARIO ODOO
#
########
USER 0


########
# VOLUMENES
#
########
VOLUME ["${ODOO_USER_HOME}/odoo-web-data", "${ODOO_APP_PATH}/addons_me"]


COPY ./entrypoint.sh /
RUN chmod 777 /entrypoint.sh

# Expose Odoo services
EXPOSE 8069 8071

# Set default user when running the container
USER odoo

# SITUO EL PROMPT EN EL DIRECTORIO DE ODOO
WORKDIR ${ODOO_APP_PATH}

ENTRYPOINT ["/entrypoint.sh"]
