{ pkgs, lib, ... }:

# inputMethod para español e inglés (Perú)
# Space + Enter para alternar entre idiomas
{
  i18n.inputMethod.enabled = "fcitx5";

  i18n.inputMethod.fcitx5.addons = with pkgs; [ 
    fcitx5-gtk 
    fcitx5-configtool
  ];

  # Configuración de fcitx5 para español/inglés
  xdg.configFile."fcitx5/config".text = ''
    [Hotkey]
    # Space + Enter para activar/desactivar IME
    TriggerKeys=
    # Control+Space como alternativa
    ActivateKeys=Control+space
    # Escape para desactivar
    DeactivateKeys=Escape

    [Hotkey/EnumerateWithTriggerKeys]
    0=True

    [Hotkey/AltTriggerKeys]
    0=Shift+space

    [Behavior]
    # Mostrar información de entrada
    ShowInputMethodInformation=True
    # Compartir estado de entrada
    ShareInputState=Program
    '';

  xdg.configFile."fcitx5/profile".text = ''
    [Groups/0]
    # Grupo por defecto
    Name=Default
    # Lista de métodos de entrada
    Default Layout=us
    DefaultIM=keyboard-us

    [Groups/0/Items/0]
    Name=keyboard-us
    Layout=

    [Groups/0/Items/1]
    Name=keyboard-es
    Layout=

    [GroupOrder]
    0=Default
    '';

  # Configuración adicional para el teclado
  xdg.configFile."fcitx5/conf/keyboard.conf".text = ''
    [Keyboard]
    # Permitir override del layout del sistema
    OverrideSystemKeyboard=True
    '';
}
