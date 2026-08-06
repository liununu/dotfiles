# local/ — local overrides

Put local override files here. Git ignores the whole directory except this file (see `../.gitignore`).

## How it works

1. Add a file to this directory.
2. Add a line to `local/.links`. Use `src=dest`. Name `dest` with one of these two forms:
   - `.<name>.local`, for a file with no extension (example: `.gitconfig.local`).
   - `.<name>.local.<ext>`, for a file with an extension (example: `.tmux.local.conf`).
3. Run `mise run tools` to symlink it.
4. The committed config loads the local file when it exists.

If a file is absent, nothing changes.

## Example

```bash
# local gitconfig overrides
cat > local/gitconfig << 'EOF'
[user]
    name = Your Name
    email = you@example.com
EOF

# extra brew packages
cat > local/Brewfile << 'EOF'
brew "jq"
cask "rectangle"
EOF

# symlink the files
cat > local/.links << 'EOF'
gitconfig=.gitconfig.local
Brewfile=.Brewfile.local
EOF

mise run tools
mise run brew
```
