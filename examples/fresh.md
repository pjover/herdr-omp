# Fresh: launch a Herdr + omp session from "New Workspace"

[Fresh](https://getfresh.dev) can start an agent in a new workspace (optionally
in a fresh git worktree). With `herdr-omp` as the agent command, that agent is a
whole Herdr session with omp already running inside it.

## Setup

1. Install `herdr-omp` so it is on the `PATH` Fresh was started with (see the
   [README](../README.md#install)).
2. In Fresh, open **New Workspace** (or **Run Agent…**).
3. Fill in the dialog:

   | Field | Value |
   |---|---|
   | Launch in | `New workspace` |
   | Agent | `custom…` |
   | Agent Command | `herdr-omp` |
   | Prompt | leave empty: custom agents do not receive it |
   | Folder | the project; Fresh may offer to branch a new worktree from it |

4. **Launch**.

Fresh remembers the last agent command, so after the first time it is
pre-filled.

## What happens

- Fresh creates the workspace folder (or worktree) and runs `herdr-omp` directly
  as the terminal's process, with that folder as the working directory. No shell
  is involved: Fresh splits the command on spaces and honours `'` / `"` quotes.
- `herdr-omp` names the Herdr session after the folder, e.g. `my-app-1`, opens a
  workspace there and starts omp in it.
- Closing the Fresh terminal detaches the Herdr client only. The Herdr server,
  and omp in it, keep running. Reopening the Fresh workspace (or restarting
  Fresh, which re-runs the command) reattaches to the same session.

## Variations

- Fixed session name, e.g. one per project regardless of worktree:
  `herdr-omp my-app`.
- Session name with spaces: `herdr-omp 'my app'`.
