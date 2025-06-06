#!/usr/bin/env bash

# Script para arreglar problemas de terminal en NixOS
# Ejecutar con: bash fix-terminal-issues.sh

set -e

echo "🔧 Aplicando correcciones para problemas de terminal..."

# Reconstruir la configuración de NixOS
echo "📦 Reconstruyendo configuración del sistema..."
sudo nixos-rebuild switch --flake .

# Reconstruir la configuración de Home Manager
echo "🏠 Reconstruyendo configuración de usuario..."
home-manager switch --flake .

# Limpiar caché de bash
echo "🧹 Limpiando caché de bash..."
hash -r

# Recargar configuración de readline
echo "📝 Recargando configuración de readline..."
bind -f ~/.inputrc 2>/dev/null || true

# Verificar que grep está disponible
echo "🔍 Verificando disponibilidad de comandos básicos..."
if command -v grep >/dev/null 2>&1; then
    echo "✅ grep está disponible"
else
    echo "❌ grep no está disponible - puede requerir reinicio"
fi

# Verificar que starship está funcionando
if command -v starship >/dev/null 2>&1; then
    echo "✅ starship está disponible"
    starship --version
else
    echo "❌ starship no está disponible"
fi

echo ""
echo "🎉 Correcciones aplicadas. Cambios realizados:"
echo "   • Añadido grep y herramientas básicas del sistema"
echo "   • Configurada gestión de energía para evitar suspensión automática"
echo "   • Simplificado el prompt de Starship (julisa@julixos:~/ >)"
echo "   • Mejorada visibilidad del tab completion"
echo "   • Deshabilitado blesh temporalmente para evitar códigos de escape"
echo ""
echo "📋 Para aplicar completamente los cambios:"
echo "   1. Cierra y abre una nueva terminal en Alacritty"
echo "   2. O ejecuta: source ~/.bashrc"
echo ""
echo "🚨 Si persisten los problemas, puede ser necesario reiniciar el sistema"