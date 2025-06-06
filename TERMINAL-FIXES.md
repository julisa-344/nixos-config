# Correcciones de Problemas de Terminal

## Problemas Solucionados

### 1. Error "grep: orden no encontrada"
**Problema**: El comando `grep` no estaba disponible en el sistema
**Solución**: Añadido `coreutils`, `gnugrep` y otras herramientas básicas del sistema en [`configuration.nix`](configuration.nix:96)

### 2. Suspensión automática del sistema
**Problema**: El PC se suspendía automáticamente después de un tiempo
**Solución**: Configurada gestión de energía en [`configuration.nix`](configuration.nix:111) para deshabilitar suspensión automática

### 3. Prompt con códigos de escape
**Problema**: El prompt mostraba `\[\]╭─\[\] \[\] 󰉋 ~ \[\]` en lugar del formato deseado
**Solución**: 
- Simplificado [`starship.toml`](users/julisa/modules/starship/starship.toml:1) para mostrar formato `julisa@julixos:~/ >`
- Deshabilitado temporalmente `blesh` en [`init.bash`](users/julisa/modules/bash/init.bash:69)

### 4. Tab completion invisible
**Problema**: Las opciones de autocompletado no eran visibles al presionar Tab
**Solución**: 
- Añadido archivo [`.inputrc`](users/julisa/modules/bash/inputrc:1) con configuración de colores
- Mejorada configuración de colores en [`init.bash`](users/julisa/modules/bash/init.bash:31)

## Cómo Aplicar las Correcciones

1. **Ejecutar el script de corrección:**
   ```bash
   ./fix-terminal-issues.sh
   ```

2. **O aplicar manualmente:**
   ```bash
   # Reconstruir sistema
   sudo nixos-rebuild switch --flake .
   
   # Reconstruir configuración de usuario
   home-manager switch --flake .
   
   # Recargar bash
   source ~/.bashrc
   ```

3. **Abrir nueva terminal** en Alacritty para ver los cambios

## Estado Esperado Después de las Correcciones

- ✅ El comando `grep` funciona correctamente
- ✅ El sistema no se suspende automáticamente
- ✅ El prompt muestra: `julisa@julixos:~/ >`
- ✅ El tab completion es visible con colores
- ✅ No aparecen códigos de escape en el terminal

## Archivos Modificados

- [`configuration.nix`](configuration.nix) - Herramientas del sistema y gestión de energía
- [`users/julisa/modules/starship/starship.toml`](users/julisa/modules/starship/starship.toml) - Prompt simplificado
- [`users/julisa/modules/bash/init.bash`](users/julisa/modules/bash/init.bash) - Configuración de bash mejorada
- [`users/julisa/modules/bash/inputrc`](users/julisa/modules/bash/inputrc) - Configuración de readline (nuevo)
- [`users/julisa/modules/bash/default.nix`](users/julisa/modules/bash/default.nix) - Inclusión de inputrc

## Troubleshooting

Si persisten los problemas:

1. **Reiniciar el sistema** para aplicar cambios del kernel y servicios
2. **Verificar que los comandos están disponibles:**
   ```bash
   which grep
   which starship
   ```
3. **Revisar logs de error:**
   ```bash
   journalctl -xe