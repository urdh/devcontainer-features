#!/bin/sh
if type git >/dev/null 2>&1; then
    git config --global core.pager "diff-so-fancy | less --tabs=4 -RF"
    git config --global interactive.diffFilter "diff-so-fancy --patch"
fi
