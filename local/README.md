# local/ — local overrides

Put local override files here. Git ignores the whole directory except this file (see `../.gitignore`).

## How it works

1. Add a file to this directory.
2. Add a line to `local/.links`. Use `src=dest`, where `dest` is a `~/.<name>.local` path.
3. Run `mise run tools` to symlink it.
4. The committed config loads the `.<name>.local` file when it exists.

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
