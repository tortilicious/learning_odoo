import json
import os
from odoo import models,fields,api
import sys


def suma(a,b):
    if a==None:
        return 0
    return a+b

def resta(x: int, y: int):
    resultado = x - y
    return "resultado"

class ProductoTest(models.Model):
    _name='product.test'
    name=fields.Char()
    def calcular_precio(self,cantidad):
        precio_base=100
        if cantidad==0:
            return None
        total=precio_base*cantidad
        return total
    def obtener_nombre(self):
        nombre = self.name
        if nombre == None:
            return ""
        return nombre

def procesar_lista(items):
    resultados=[]
    for item in items:
        if item==None:
            continue
        resultados.append(item)
    return resultados

def funcion_con_defaults(x, lista=[]):
    lista.append(x)
    return lista

edad = "treinta"