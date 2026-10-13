# shellcheck shell=sh
# Shell helpers around herdr-omp. Source this file from ~/.zshrc or ~/.bashrc:
#
#   . /path/to/herdr-omp/examples/shell-functions.sh

# hop [DIR] [SESSION]
# Open herdr-omp in DIR (default: current directory) without changing the
# directory of the calling shell.
#
#   hop ~/src/my-app
#   hop ~/src/my-app review
hop() (
  cd "${1:-.}" && herdr-omp ${2:+"$2"}
)

# hwt BRANCH
# Create a git worktree for a new BRANCH next to the current repository
# (<repo>-<branch>) and open herdr-omp in it. The session is named after the
# worktree directory.
#
#   cd ~/src/my-app && hwt fix-login    # -> ~/src/my-app-fix-login
hwt() (
  [ -n "${1-}" ] || { echo "usage: hwt BRANCH" >&2; exit 2; }
  root=$(git rev-parse --show-toplevel) || exit
  dir="$(dirname "$root")/$(basename "$root")-$(printf '%s' "$1" | tr '/' '-')"
  git worktree add -b "$1" "$dir" && cd "$dir" && herdr-omp
)
