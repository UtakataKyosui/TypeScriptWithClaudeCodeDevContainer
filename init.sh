#!/bin/bash

set -e

echo "🚀 Initializing Claude Code MCP Development Environment..."

# Function to substitute environment variables in templates
substitute_env_vars() {
    local template_file="$1"
    local output_file="$2"
    
    if [ ! -f "$template_file" ]; then
        echo "❌ Template file $template_file not found"
        return 1
    fi
    
    echo "📝 Processing template: $template_file -> $output_file"
    
    # Use envsubst to substitute environment variables
    envsubst < "$template_file" > "$output_file"
    
    echo "✅ Created $output_file"
}

# Copy and process .env file
if [ ! -f "/workspace/.devcontainer/.env" ]; then
    if [ -f "/workspace/.devcontainer/.env.template" ]; then
        echo "📋 Copying .env template to .devcontainer..."
        substitute_env_vars "/workspace/.devcontainer/.env.template" "/workspace/.devcontainer/.env"
        echo "⚠️  Please edit /workspace/.devcontainer/.env with your actual values"
    else
        echo "❌ .env template not found"
    fi
else
    echo "ℹ️  .env already exists in .devcontainer"
fi

# Copy and process .mcp.json file
if [ ! -f "/workspace/.mcp.json" ]; then
    if [ -f "/workspace/.devcontainer/.mcp.json.template" ]; then
        echo "📋 Copying .mcp.json template to workspace..."
        substitute_env_vars "/workspace/.devcontainer/.mcp.json.template" "/workspace/.mcp.json"
        echo "✅ Created .mcp.json"
    else
        echo "❌ .mcp.json template not found"
    fi
else
    echo "ℹ️  .mcp.json already exists in workspace"
fi

# Fix npm configuration if needed
echo "🔧 Checking npm configuration..."
CURRENT_PREFIX=$(npm config get prefix)
if [[ "$CURRENT_PREFIX" == *'$USERNAME'* ]]; then
    echo "⚠️  Fixing npm prefix configuration..."
    npm config set prefix "$HOME/.npm-global"
    echo "✅ npm prefix fixed: $(npm config get prefix)"
else
    echo "✅ npm prefix is correctly configured: $CURRENT_PREFIX"
fi

# Install MCP servers
echo "📦 Preparing MCP servers..."
echo "ℹ️  MCP servers will be installed on-demand using npx when needed"
echo "ℹ️  This avoids permission issues with global npm installs"

# Ensure uv is available in PATH
echo "🐍 Verifying uv installation..."
if command -v uv &> /dev/null; then
    echo "✅ uv is available: $(uv --version)"
else
    echo "❌ uv not found - check Dockerfile multistage build"
fi

# Create Claude config directory if it doesn't exist
if [ ! -d "/home/vscode/.anthropic" ]; then
    mkdir -p /home/vscode/.anthropic
    echo "📁 Created Claude config directory"
fi


# Copy .mcp.json to Claude config directory if it exists
# if [ -f "/workspace/.mcp.json" ]; then
#     cp "/workspace/.mcp.json" "/home/vscode/.anthropic/claude_desktop_config.json"
#     echo "✅ Copied MCP configuration to Claude config directory"
# fi

alias yolo='claude --dangerously-skip-permissions'

echo "🎉 Initialization complete!"
echo ""
echo "📖 Next steps:"
echo "1. Edit /workspace/.devcontainer/.env with your GitHub token and Obsidian vault path"
echo "2. Rebuild the devcontainer to mount your Obsidian vault"
echo "3. Run 'npm install' to install dependencies"
echo "4. Use 'npm run dev' to start development server"
echo "5. Use 'claude --help' to get started with Claude CLI"
echo ""
echo "🔧 Available MCP servers:"
echo "  - mcp-obsidian: Access your Obsidian vault (mounted at /workspace/obsidian-vault)"
echo "  - github: GitHub repository access"  
echo "  - file-system: Local filesystem access"
echo "  - fetch: Web fetch capabilities"
echo "  - docker: Docker container management"
echo "  - playwright: Browser automation and testing"
echo ""
echo "📝 TypeScript development commands:"
echo "  - npm run dev: Start development server with hot reload"
echo "  - npm run build: Build the project"
echo "  - npm run lint: Run ESLint"
echo "  - npm run format: Format code with Prettier"