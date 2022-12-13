#!/usr/bin/env python3

"""
    ATENCIÓN
    SI NO FUNCIONA PTVSD, PROBAR A PONER EN odoo.conf workers = 0
"""

import os

import socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.close()

import ptvsd
#ptvsd.enable_attach(address=('0.0.0.0', 3000), redirect_output=True)
ptvsd.enable_attach(address=('0.0.0.0', 3000), redirect_output=True)
print('ptvsd is started')

ptvsd.wait_for_attach()
print('debugger is attached')

import sys
if sys.modules.get("gevent") is not None:
    evented = True 

# set server timezone in UTC before time module imported
__import__('os').environ['TZ'] = 'UTC'
import odoo

if __name__ == "__main__":
    odoo.cli.main()

exit()