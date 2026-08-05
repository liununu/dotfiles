# dotfiles

## Quick start

Install the prerequisites manually:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install mise
```

Apply configuration:

```bash
mise run bootstrap                  # Interactive multi-select menu
mise run bootstrap -- all           # Run every step in order
mise run bootstrap -- tools brew    # Run specific steps
```

## Day-to-day commands

```bash
mise run shellcheck       # Lint shell scripts
mise run defaults:diff    # Print the `defaults write` command for a settings change
mise run brew:dump        # Write installed packages to Brewfile
```

## Add a new tool

A tool is a directory that holds the files of one program. Each tool directory can contain a `.links` manifest and an optional `.setup` script. The bootstrap step discovers tool directories by these two files.

### 1. Create the tool directory

Put the files for the program in a new directory under the repository root.

```bash
mkdir starship/
cp ~/.config/starship.toml starship/starship.toml
```

### 2. Declare what to symlink

Create `.links` in the tool directory. Use one line per entry. Each line has the form `src=dest`. The `src` is relative to the tool directory. The `dest` is relative to `$HOME`. Use `.` as the source to symlink the whole directory.

```bash
cat > starship/.links << 'EOF'
starship.toml=.config/starship.toml
EOF
```

### 3. Add a setup script (optional)

Add `.setup` when the tool needs work beyond a symlink. For example, clone a plugin manager before first use. The script must be executable. It must also be safe to run more than once.

```bash
cat > tmux/.setup << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR/.git" ]; then
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
EOF
chmod +x tmux/.setup
```

### 4. Apply the tool

Run the tools step. It applies `.links` first, then runs `.setup`, for each tool directory.

```bash
mise run bootstrap -- tools
```

## Local overrides

Local overrides use the `.local` name, like `.env.local`. Each committed config loads a `.local` file when it exists. These files live in `local/` at the repo root. See [`local/README.md`](local/README.md).

Git ignores `local/` except `local/README.md`. Never `git add -f` anything in it.
