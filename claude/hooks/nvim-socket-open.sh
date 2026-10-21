#!/bin/bash

# Read the JSON input from stdin
INPUT=$(cat)
echo "$INPUT" >/tmp/nvim-hook.log

# Extract the edited file path from the hook input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path' 2>/dev/null)

# Extract the line number from the first structured patch
# newStart is the beginning of the patch, we need to find the first + line
NEW_START=$(echo "$INPUT" | jq -r '.tool_response.structuredPatch[0].newStart // empty' 2>/dev/null)

# Find the offset to the first + line in the patch, ignoring removed (-) lines
# since they don't exist in the new file
PLUS_LINE_OFFSET=$(echo "$INPUT" | jq -r '
  .tool_response.structuredPatch[0].lines // []
  | map(select(startswith("-") | not))
  | to_entries
  | map(select(.value | startswith("+")))
  | .[0].key // 0
' 2>/dev/null)

# Calculate the actual line number of the edit
if [ -n "$NEW_START" ] && [ -n "$PLUS_LINE_OFFSET" ]; then
  EDIT_LINE=$((NEW_START + PLUS_LINE_OFFSET))
else
  EDIT_LINE=""
fi

# Get the current herdr workspace label or tmux session name
if [ -n "$HERDR_WORKSPACE_ID" ]; then
  SESSION_NAME=$(herdr workspace get "$HERDR_WORKSPACE_ID" 2>/dev/null | jq -r '.result.workspace.label // empty')
  SESSION_NAME="${SESSION_NAME//[^A-Za-z0-9_.-]/_}"
else
  SESSION_NAME=$(tmux display-message -p '#{session_name}' 2>/dev/null)
fi

# Only proceed if we have both file path and session name
if [ -z "$FILE_PATH" ] || [ -z "$SESSION_NAME" ]; then
  exit 0
fi

# Open the file in the Neovim instance for this tmux session
nvim --server "/tmp/nvim-${SESSION_NAME}.sock" --remote "$FILE_PATH" 2>/dev/null

# If we have a line number, navigate to it using remote-send
if [ -n "$EDIT_LINE" ]; then
  nvim --server "/tmp/nvim-${SESSION_NAME}.sock" --remote-send ":${EDIT_LINE}<CR>" 2>/dev/null
fi

exit 0
