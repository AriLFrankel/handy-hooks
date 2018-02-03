#!/bin/bash

main () {
  local root="$(git rev-parse --show-toplevel)"
  local hook=$root/.git/hooks/post-commit
  # disable post-commit hook temporarily
  # to avoid recursively calling post-commit
  chmod -x $hook

  # reset the AUTHORS file
  echo -e $"# Authors orderd by date of first contribution \n\n" > $root/AUTHORS

  # get authors name <email> contribution date in order
  # remove bracketed text such as '[user]'
  # and contributions not associated with a git account (ending in .local)
  # filter unique by email address
  # sort by date of contribution again after deduping
  # remove date of contribution
  # output to AUTHORS file
  git log --format='%ad %an <%ae>' --date="short" --reverse | sed -e 's/\[.*\]//' -e '/.local>$/c\' | rev | sort -k 1,1 -u | rev | sort -n -t"-" -k1 -k2 -k3 | sed -e 's/^[0-9\-]*//' >> $root/AUTHORS

  # commit AUTHORS
  git add $root/AUTHORS

  git commit --amend --no-edit --no-verify

  # re-enable post-commit for the next commit
  chmod +x $hook
}

main
