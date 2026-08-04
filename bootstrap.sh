#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

info()    { printf '  \033[1;36m%s\033[0m\n' "$*"; }
success() { printf '  \033[32m%s\033[0m\n' "$*"; }
warn()    { printf '  \033[33m%s\033[0m\n' "$*"; }
fail()    { printf '  \033[31m%s\033[0m\n' "$*" >&2; exit 1; }

link() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    if [ -L "$dest" ]; then
        ln -sfn "$src" "$dest"
    elif [ -e "$dest" ]; then
        warn "skip $dest (real file exists)"
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

    while IFS='=' read -r src dest; do
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
do_tools() {
    info "Tools"

    while IFS= read -r dir; do
        [[ -f "$dir/.links" ]] && link_from_manifest "$dir/.links"
        if [[ -f "$dir/.setup" ]] && [ -x "$dir/.setup" ]; then
            info "→ ${dir#./} .setup"
            "$REPO_ROOT/$dir/.setup"
        fi
    done < <(discover_tools)
}

do_brew() {
    info "Homebrew"
    command -v brew >/dev/null 2>&1 || fail "Homebrew not found. Install: https://brew.sh"
    brew analytics off
    brew bundle check --no-upgrade --file "$REPO_ROOT/Brewfile" >/dev/null 2>&1 \
        && { success "all packages installed"; return; }
    brew bundle install --no-upgrade --file "$REPO_ROOT/Brewfile"
    success "packages installed"
}

do_defaults() {
    info "macOS defaults"
    [[ "$(uname -s)" == "Darwin" ]] || { warn "not Darwin, skipping"; return; }
    . "$REPO_ROOT/macos/defaults.sh"
    success "macOS defaults set"
}

MODE="${1:-all}"

case "$MODE" in
    --tools)    do_tools ;;
    --brew)     do_brew ;;
    --defaults) do_defaults ;;
    all)
        do_brew
        do_tools
        do_defaults
        ;;
    *) fail "unknown option: $MODE." ;;
esac

echo ""
success "Done."
