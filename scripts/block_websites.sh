#!/usr/bin/env bash
# Temporarily block/unblock distracting sites via /etc/hosts.
# Source list: 081626/websites_i_frequently_visit.md
#
# Source this file from your .zshrc, then call directly:
#   block_websites
#   unblock_websites
#   website_block_status

_website_block_domains=(
  mlb.com
  www.mlb.com
  milb.com
  www.milb.com
  perfectcircuit.com
  www.perfectcircuit.com
  news.ycombinator.com
  dailyecho.co.uk
  www.dailyecho.co.uk
  redlegnation.com
  www.redlegnation.com
  theguardian.com
  www.theguardian.com
  bsky.app
)

_website_block_hosts_file="/etc/hosts"
_website_block_mark_begin="# BEGIN temp-block (websites_i_frequently_visit)"
_website_block_mark_end="# END temp-block (websites_i_frequently_visit)"

block_websites() (
  set -euo pipefail
  if grep -q "$_website_block_mark_begin" "$_website_block_hosts_file" 2>/dev/null; then
    echo "Already blocked. Run 'unblock_websites' first to refresh, or 'website_block_status' to check."
    return 1
  fi
  {
    echo "$_website_block_mark_begin"
    for d in "${_website_block_domains[@]}"; do
      echo "0.0.0.0 $d"
    done
    echo "$_website_block_mark_end"
  } | sudo tee -a "$_website_block_hosts_file" >/dev/null
  echo "Blocked ${#_website_block_domains[@]} entries. Restart your browser (or open a new tab) for it to take effect."
)

unblock_websites() (
  set -euo pipefail
  if ! grep -q "$_website_block_mark_begin" "$_website_block_hosts_file" 2>/dev/null; then
    echo "Nothing to unblock."
    return 0
  fi
  sudo sed -i "/$_website_block_mark_begin/,/$_website_block_mark_end/d" "$_website_block_hosts_file"
  echo "Unblocked."
)

website_block_status() (
  set -euo pipefail
  if grep -q "$_website_block_mark_begin" "$_website_block_hosts_file" 2>/dev/null; then
    echo "Currently blocked:"
    sed -n "/$_website_block_mark_begin/,/$_website_block_mark_end/p" "$_website_block_hosts_file"
  else
    echo "Not currently blocked."
  fi
)
