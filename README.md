# dotfiles

## Quick start

Install the prerequisites manually:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install mise
```

Apply the configuration:

```bash
mise run setup
```

Run one step at a time:

```bash
mise run link       # symlinks only
mise run brew       # packages only
mise run defaults   # macOS defaults only
```

## Day-to-day commands

```bash
mise run shellcheck       # lint shell scripts
mise run defaults:diff    # discover what defaults changed after toggling a macOS setting
mise run brew:dump        # dump installed packages into Brewfile
```

## Add a new config

Add a file to an existing tool dir. Then append one line to its `.links` file:

```bash
echo 'starship.toml=.config/starship.toml' >> nvim/.links
cp ~/.config/starship.toml nvim/starship.toml
mise run link
```

Add a new tool dir. Create the dir, copy the files, then write a `.links` file:

```bash
mkdir starship/
cp ~/.config/starship.toml starship/starship.toml
cat > starship/.links << 'EOF'
starship.toml=.config/starship.toml
EOF
mise run link
```

Symlink a whole directory. Use `.` as the source value:

```
# mytool/.links
.=.mytool
```

`.links` format: `src=dest`. `src` is relative to the tool dir. `dest` is relative to `$HOME`. The value `.` means the whole directory. 
