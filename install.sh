curl -fsSL https://claude.ai/install.sh | bash

[ -d "~/.claude" ] || mkdir -p ~/.claude

ln -s ~/claude_code/agents ~/.claude/agents
ln -s ~/claude_code/rules ~/.claude/rules
ln -s ~/claude_code/skills ~/.claude/skills

