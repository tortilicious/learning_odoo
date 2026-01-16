#!/bin/bash
# lint.sh - Script para verificar código

if [ -z "$1" ]; then
    echo "Uso: ./lint.sh <archivo_o_directorio>"
    exit 1
fi

echo "📁 Procesando: $1"
echo ""

echo "🎨 Paso 1/4: Formateando código..."
ruff format "$1"
echo ""

echo "🔧 Paso 2/4: Arreglando errores automáticos..."
ruff check --fix --unsafe-fixes "$1"
echo ""

echo "📝 Paso 3/4: Verificando estilo..."
if ruff check "$1"; then
    echo "✅ Estilo correcto"
else
    echo "⚠️  Hay errores de estilo que debes arreglar manualmente"
fi
echo ""

echo "🔍 Paso 4/4: Verificando tipos..."
if ty check "$1"; then
    echo "✅ Tipos correctos"
else
    echo "⚠️  Hay errores de tipos que debes arreglar manualmente"
fi
echo ""

echo "🎉 ¡Proceso completado!"