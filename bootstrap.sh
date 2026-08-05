#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

info()    { gum log --level info "$*"; }
success() { gum log --level info "✓ $*"; }
warn()    { gum log --level warn "$*"; }
fail()    { gum log --level fatal "$*"; exit 1; }

link() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    if [ -L "$dest" ]; then
        ln -sfn "$src" "$dest"
        success "linked ~/${dest#"$HOME"/} (refreshed)"
    elif [ -e "$dest" ]; then
        if gum confirm "Overwrite ~/${dest#"$HOME"/}? (dest file exists)" </dev/null; then
            rm -f "$dest"
            ln -sfn "$src" "$dest"
            success "linked ~/${dest#"$HOME"/}"
        else
            warn "skip $dest (real file exists)"
        fi
        return
    else
        ln -s "$src" "$dest"
        success "linked ~/${dest#"$HOME"/}"
    fi
}

# Tool dirs are any directory containing a .links manifest and/or a .setup script.
# Both are optional.
discover_tools() {
    find . -maxdepth 2 \( -name '.links' -o -name '.setup' \) \
        -not -path './.git/*' \
        -exec dirname {} \; | sort -u
}

# Apply .links manifest.
# Format: src=dest (both relative — src to tool dir, dest to $HOME)
#   .zshrc=.zshrc                       → file symlink
#   .=.hammerspoon                      → directory symlink
link_from_manifest() {
    local linksfile="$1" dir
    dir="$(dirname "$linksfile")"

    while IFS='=' read -r src dest || [[ -n "$src" ]]; do
        # Skip comments and empty lines
        [[ -z "$src" || "$src" == \#* ]] && continue

        if [[ "$src" == "." ]]; then
            link "$REPO_ROOT/$dir" "$HOME/$dest"
        else
            link "$REPO_ROOT/$dir/$src" "$HOME/$dest"
        fi
    done < "$linksfile"
}

# Per-tool: link .links first, then run .setup (if present).
# Read tool dirs into an array first, then iterate. Feeding the loop through
# stdin would let gum confirm drain that stream and make later tool dirs
# silently drop.
do_tools() {
    info "Tools"

    local dirs=() dir
    while IFS= read -r dir; do
        dirs+=("$dir")
    done < <(discover_tools)

    for dir in "${dirs[@]}"; do
        [[ -f "$dir/.links" ]] && link_from_manifest "$dir/.links"
        if [[ -f "$dir/.setup" ]] && [ -x "$dir/.setup" ]; then
            info "→ ${dir#./} .setup"
            gum spin --spinner dot --show-output --title "Running ${dir#./} .setup..." -- "$REPO_ROOT/$dir/.setup"
        fi
    done
}

do_brew() {
    info "Homebrew"
    command -v brew >/dev/null 2>&1 || fail "Homebrew not found. Install: https://brew.sh"
    brew analytics off

    brew_bundle() {
        local file="$1"
        [ -f "$file" ] || return 0
        if gum spin --spinner dot --title "Checking $(basename "$file")..." -- brew bundle check --no-upgrade --file "$file"; then
            return 0
        fi
        gum spin --spinner dot --show-output --title "Installing $(basename "$file")..." -- brew bundle install --no-upgrade --file "$file"
    }

    brew_bundle "$REPO_ROOT/Brewfile"
    brew_bundle "$HOME/.Brewfile.local"
    success "packages installed"
}

do_defaults() {
    info "macOS defaults"
    [[ "$(uname -s)" == "Darwin" ]] || { warn "not Darwin, skipping"; return; }
    . "$REPO_ROOT/macos/defaults.sh"
    success "macOS defaults set"
}

# With no argument, open an interactive menu to pick a step.
# With an argument, run that step directly.
if [[ $# -eq 0 ]]; then
    MODE=$(gum choose --header "What do you want to do?" brew tools defaults all exit) || exit 0
    [[ "$MODE" == "exit" ]] && exit 0
else
    MODE="$1"
fi

case "$MODE" in
    tools|--tools)        do_tools ;;
    brew|--brew)          do_brew ;;
    defaults|--defaults)  do_defaults ;;
    all)
        gum confirm "Run full bootstrap?" || exit 0
        do_brew
        do_tools
        do_defaults
        ;;
    *) fail "unknown option: $MODE." ;;
esac

echo ""
success "Done."
