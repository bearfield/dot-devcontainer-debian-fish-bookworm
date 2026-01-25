set -g theme_date_timezone UTC
set -g theme_date_format "+%F %H:%M:%S (%Z)"
set -g theme_color_scheme solarized
set -g theme_newline_cursor yes

set fish_color_command brpurple

set -x CLOUDSDK_ACTIVE_CONFIG_NAME

# Python aliases
alias py="python3"
alias pip="uv pip"
alias pytest="uv tool run pytest"
alias ruff="uv tool run ruff"
alias black="uv tool run black"
alias mypy="uv tool run mypy"
alias ipython="uv tool run ipython"

# Add npm user global bin to PATH
set -gx PATH $HOME/.npm-global/bin $PATH

# Add Claude Code native binary to PATH (installed to ~/.local/bin)
set -gx PATH $HOME/.local/bin $PATH

# cdx: short form wrapper (config-driven)
function cdx
    command codex $argv
end
