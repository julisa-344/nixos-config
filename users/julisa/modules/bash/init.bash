# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# Configuración mejorada del historial
HISTSIZE=10000              # Número de comandos en memoria
HISTFILESIZE=20000          # Número de comandos en el archivo de historial
HISTTIMEFORMAT="[%F %T] "   # Formato de tiempo para el historial
shopt -s histappend         # Agregar al historial en lugar de sobrescribir
shopt -s histverify         # Verificar expansiones del historial
shopt -s histreedit         # Permitir reeditar comandos del historial

# Búsqueda inteligente en el historial
# Ctrl+R para búsqueda reversa mejorada
bind '"\C-r": reverse-search-history'
# Flecha arriba/abajo para búsqueda basada en el prefijo actual
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
# Alt+< y Alt+> para navegar por el historial
bind '"\e<": beginning-of-history'
bind '"\e>": end-of-history'

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# Configurar colores para tab completion visible
export LS_COLORS='di=1;34:fi=0:ln=1;36:pi=40;33:so=1;35:do=1;35:bd=40;33;1:cd=40;33;1:or=40;31;1:ex=1;32:*.tar=1;31'

# enable color support of ls and also add handy aliases
if command -v dircolors >/dev/null 2>&1; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# Configuración mejorada para tab completion
set colored-stats on
set colored-completion-prefix on
set show-all-if-ambiguous on
set show-all-if-unmodified on
set completion-ignore-case on
set mark-symlinked-directories on

# some more ls aliases
alias ls='lsd'
alias ll='ls -alF'
alias la='ls -A'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

## home manager workaround
export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}

# Verificar si existe npm-completion antes de cargarlo
if [ -f ~/.bash_completion.d/npm-completion ]; then
  source ~/.bash_completion.d/npm-completion
fi

# Configurar BLESH solo si está disponible y no causa problemas
if command -v blesh-path >/dev/null 2>&1; then
  BLESH_PATH="$(blesh-path)"
  if [ -f "$BLESH_PATH" ]; then
    # Deshabilitar blesh temporalmente para evitar problemas con códigos de escape
    # source $BLESH_PATH
    echo "BLESH disponible pero deshabilitado para evitar problemas de prompt"
  fi
fi

# Configurar variables de entorno para colores
export TERM=xterm-256color
export COLORTERM=truecolor

# neofetch
