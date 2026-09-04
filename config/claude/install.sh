#!/bin/sh
set -eu

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

install_link() {
  source=$1
  destination=$2

  mkdir -p "${destination%/*}"
  if [ -e "$destination" ] || [ -L "$destination" ]; then
    source_target=$(realpath "$source")
    destination_target=$(realpath "$destination" 2>/dev/null || true)
    if [ "$destination_target" != "$source_target" ]; then
      printf 'Refusing to replace %s\n' "$destination" >&2
      exit 1
    fi
    return
  fi
  ln -s "$source" "$destination"
}

merge_settings() {
  destination=$1
  source=$2

  mkdir -p "${destination%/*}"
  if ! [ -e "$destination" ]; then
    printf '{}\n' >"$destination"
    chmod 600 "$destination"
  fi

  temporary=$(mktemp "${destination%/*}/.claude-settings.XXXXXX")
  trap 'rm -f "$temporary"' EXIT HUP INT TERM
  chmod 600 "$temporary"
  jq --slurpfile ours "$source" '
    (.hooks // {}) as $hooks
    | .hooks = ($hooks | with_entries(
        .value |= map(select(
          ([.hooks[]?.command // ""] | any(contains("nvim-socket-open.sh"))) | not
        ))
      ))
    | .hooks.PostToolUse = (
        (.hooks.PostToolUse // []) + ($ours[0].hooks.PostToolUse // []) | unique_by(tostring)
      )
    | .["$schema"] = (.["$schema"] // $ours[0]["$schema"])
  ' "$destination" >"$temporary"
  jq -e 'type == "object" and (.hooks.PostToolUse | type == "array")' "$temporary" >/dev/null
  mv "$temporary" "$destination"
  trap - EXIT HUP INT TERM
}

install_link "$script_dir/hooks/nvim-socket-open.sh" "$HOME/.claude/hooks/nvim-socket-open.sh"
merge_settings "$HOME/.claude/settings.json" "$script_dir/settings.json"
