# Powerlevel10k configuration - Estilo Powerline con flechas
# Para reconfigurar ejecuta: p10k configure

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  autoload -Uz is-at-least && is-at-least 5.1 || return

  # Prompt characters
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND=76
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND=196

  # Separators - Flechas estilo Powerline
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=' '

  # Mode
  typeset -g POWERLEVEL9K_MODE='nerdfont-complete'

  # Instant prompt
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose

  # Elementos del prompt
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    context                 # user@hostname
    dir                     # current directory
    vcs                     # git status
    prompt_char             # prompt symbol
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status                  # exit code
    command_execution_time  # duration
    time                    # current time
  )

  # === CONTEXT (user@host) ===
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=255
  typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=31
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=255
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND=160
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=
  typeset -g POWERLEVEL9K_ALWAYS_SHOW_CONTEXT=true

  # === DIRECTORY ===
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=255
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=31
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=3
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3

  # Home
  typeset -g POWERLEVEL9K_DIR_HOME_FOREGROUND=255
  typeset -g POWERLEVEL9K_DIR_HOME_BACKGROUND=31
  # Home subdirectory
  typeset -g POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND=255
  typeset -g POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND=31
  # Non-writable
  typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_FOREGROUND=255
  typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_BACKGROUND=196
  # Default
  typeset -g POWERLEVEL9K_DIR_DEFAULT_FOREGROUND=255
  typeset -g POWERLEVEL9K_DIR_DEFAULT_BACKGROUND=31

  # === VCS (Git) ===
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=255
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=34
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=255
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=130
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=255
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=130
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND=255
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=196
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=244

  # Git icons
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '
  typeset -g POWERLEVEL9K_VCS_COMMIT_ICON='@'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON='!'
  typeset -g POWERLEVEL9K_VCS_STAGED_ICON='+'

  # Async git status
  typeset -g POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS=0
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)

  # === STATUS ===
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=70
  typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=0
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=196
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=0
  typeset -g POWERLEVEL9K_STATUS_VERBOSE=true

  # === COMMAND EXECUTION TIME ===
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=248
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

  # === TIME ===
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=248
  typeset -g POWERLEVEL9K_TIME_BACKGROUND=0
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=true

  # === Transient prompt ===
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off

  # === Hot reload ===
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  (( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
  'builtin' 'unset' 'p10k_config_opts'
}

# Cargar p10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
