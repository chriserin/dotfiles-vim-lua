if type "op" > /dev/null; then
  eval "$(op completion zsh)"
  compdef _op op


  # Enable SSH Agent for all hosts
  export SSH_AUTH_SOCK=~/.1password/agent.sock

  # prevent an issue with TELEPORT conflicting with 1password agent
  export TELEPORT_ADD_KEYS_TO_AGENT=no
fi
