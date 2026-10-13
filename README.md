# herdr-omp

Open a [Herdr](https://herdr.dev) session for the current directory with the
[omp](https://github.com/can1357/oh-my-pi) coding agent already running in it,
or reattach to it if it exists.

```sh
cd ~/src/my-app
herdr-omp            # session "my-app": workspace in ~/src/my-app, omp in its first pane
```

Herdr has no flag to launch a session in a given directory with a given
command. `herdr-omp` adds that as one command, so anything that can run a
command in a folder (a shell, an editor's "launch agent" dialog, a git
worktree script) can open an agent session that keeps running in the
background.

## Requirements

| Tool | Tested with | Install |
|---|---|---|
| [Herdr](https://herdr.dev) | 0.9.2, 0.9.3 | `curl -fsSL https://herdr.dev/install.sh \| sh` ([other methods](https://herdr.dev/docs/install/)) |
| [omp](https://github.com/can1357/oh-my-pi) | 18.10.2, 18.10.3 | `curl -fsSL https://omp.sh/install \| sh` |
| POSIX `sh`, `awk`, `sed`, `tr` | macOS 27 (BSD tools), Arch Linux ARM (GNU tools, `sh` = bash) | preinstalled on macOS and Linux |

Optional:

- The Herdr omp integration, so omp resumes its conversation when a stopped
  session is reopened: `herdr integration install omp`.
- [Fresh](https://getfresh.dev) 0.5.3+, to launch sessions from its
  New Workspace dialog: see [examples/fresh.md](examples/fresh.md).

## Install

Download the script to a directory on your `PATH`:

```sh
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/pjover/herdr-omp/master/bin/herdr-omp -o ~/.local/bin/herdr-omp
chmod +x ~/.local/bin/herdr-omp
```

Or from a clone, symlinked so `git pull` updates it:

```sh
git clone https://github.com/pjover/herdr-omp.git
ln -s "$PWD/herdr-omp/bin/herdr-omp" ~/.local/bin/herdr-omp
```

Check it is found: `herdr-omp --help`.

To uninstall, delete `~/.local/bin/herdr-omp`.

## Usage

```
herdr-omp [SESSION]
```

| Situation | What happens |
|---|---|
| Session does not exist | Herdr creates it, with one workspace in the current directory; omp is started in that workspace's first pane; you are attached. |
| Session is running | You are attached. Nothing is created. |
| Session is stopped | Herdr restores its saved workspaces and you are attached. With the omp integration installed, omp resumes its conversation. |

`SESSION` defaults to the current directory's name, with characters other than
`A-Z a-z 0-9 _ . -` replaced by `-`. So each project (or git worktree) gets its
own session, and running `herdr-omp` again in the same directory returns to it.

Detach with Herdr's `prefix+q` (`ctrl+b`, then `q`) or just close the
terminal: the session and omp keep running. Stop a session with
`herdr session stop SESSION`; delete it with `herdr session delete SESSION`.

## Examples

- **Shell helpers** ([examples/shell-functions.sh](examples/shell-functions.sh)):
  `hop DIR` opens a session for another directory without `cd`-ing your shell;
  `hwt BRANCH` creates a git worktree for a new branch and opens a session in it.
- **Fresh editor** ([examples/fresh.md](examples/fresh.md)): set the New
  Workspace dialog's agent to `custom…` with command `herdr-omp`.

## How it works

1. `herdr session list` tells whether the session already exists.
2. If not, a background helper waits for the new session's first pane (polling
   `herdr --session SESSION pane list` every 0.2 s, for up to 20 s) and runs
   `herdr agent start omp --kind omp --pane PANE`. That waits until omp is
   ready for input, and Herdr tracks it as an agent.
3. The script then `exec`s `herdr --session SESSION`. For a new session, this
   starts the Herdr server detached from the terminal and opens a workspace in
   the current directory. That is the pane the helper starts omp in.

Because the server is detached, closing the terminal that ran `herdr-omp`
(or killing its process group) only drops the client.

## Troubleshooting

- **omp did not start in a new session.** The helper's output is discarded so
  it does not draw over the Herdr UI. Run the same steps by hand to see the
  error:
  `herdr --session SESSION pane list`, then
  `herdr --session SESSION agent start omp --kind omp --pane PANE`.
  `agent start` needs the pane to be at a shell prompt.
- **A reopened session shows a shell instead of omp.** Install the integration
  (`herdr integration install omp`) and restart omp once so it loads.
  If omp was never sent a message, there is no saved conversation to resume:
  omp prints `Session "…" not found` and the pane falls back to the shell.
- **Running it from inside a Herdr pane does nothing useful.** Herdr blocks
  launching itself inside a pane it manages unless `allow_nested = true` is
  set under `[experimental]` in `~/.config/herdr/config.toml`.
- **A directory named like an existing session** (for example `default`)
  attaches to that session instead of creating one. Pass a name:
  `herdr-omp my-name`.
- Herdr logs for a named session are in `~/.config/herdr/sessions/SESSION/`.

## License

[GPL-3.0-or-later](LICENSE). Copyright (C) 2026 Pere Jover.
