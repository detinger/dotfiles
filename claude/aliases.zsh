# Claude Code multi-account aliases
# Personal Pro account uses the default ~/.claude dir
alias claude-private='CLAUDE_CONFIG_DIR="$HOME/.claude" claude'
alias claude-work='CLAUDE_CONFIG_DIR="$HOME/.claude-work" claude'
alias claude-private-status='CLAUDE_CONFIG_DIR="$HOME/.claude" claude auth status'
alias claude-work-status='CLAUDE_CONFIG_DIR="$HOME/.claude-work" claude auth status'

# VS Code — extension inherits CLAUDE_CONFIG_DIR from the launch environment
alias code-work='CLAUDE_CONFIG_DIR="$HOME/.claude-work" code'
alias code-private='CLAUDE_CONFIG_DIR="$HOME/.claude" code'
