#!/usr/bin/env bash

echo "🚀 Aplicando mejoras al terminal y sistema..."

# Reconstruir la configuración de NixOS
echo "📦 Reconstruyendo configuración de Home Manager..."
home-manager switch

# Reiniciar polybar para aplicar los nuevos módulos
echo "🔄 Reiniciando polybar..."
systemctl --user restart polybar

# Reiniciar i3 para aplicar la nueva configuración de terminal
echo "🪟 Recargando configuración de i3..."
i3-msg reload

echo "✅ ¡Mejoras aplicadas!"
echo ""
echo "🎯 Resumen de mejoras:"
echo "  • Alacritty configurado con colores Catppuccin Mocha"
echo "  • Historial inteligente en bash (usa ↑/↓ para buscar por prefijo)"
echo "  • Luz nocturna arreglada en la barra de polybar"
echo "  • Indicador de pantallas múltiples agregado"
echo "  • Prompt de Starship mejorado con colores Catppuccin"
echo ""
echo "🔧 Comandos útiles:"
echo "  • Super+T: Abrir Alacritty"
echo "  • Super+G: Alternar luz nocturna"
echo "  • Escribir 'cle' y presionar ↑: Ver comandos que empiezan con 'cle'"
echo "  • Ctrl+R: Búsqueda reversa en historial"
echo ""
echo "🖥️  Para configurar múltiples pantallas:"
echo "  • Haz clic en el indicador de pantallas en la barra"
echo "  • O ejecuta 'arandr' manualmente"

# Abrir una nueva terminal para probar
echo ""
echo "🧪 Abriendo nueva terminal para probar..."
alacritty &