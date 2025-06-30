# Obsidian Vault Synchronization Setup

This devcontainer is configured to synchronize your local Obsidian vault with the development environment.

## Setup Instructions

1. **Configure Environment Variables**
   - Copy `.env.template` to `.env` in the `.devcontainer` directory
   - Set `OBSIDIAN_VAULT_PATH` to the absolute path of your Obsidian vault on the host system
   
   Example:
   ```
   OBSIDIAN_VAULT_PATH=/Users/username/Documents/MyObsidianVault
   ```

2. **Rebuild Devcontainer**
   - After setting the environment variables, rebuild the devcontainer
   - This will mount your Obsidian vault at `/workspace/obsidian-vault`

3. **Install QuickDraft Plugin**
   - Copy the built plugin from `/workspace/quickdraft` to your vault's plugins directory
   - Or use the provided installation script (if available)

## Volume Mount Configuration

The docker-compose.yml file includes:
```yaml
volumes:
  - ${OBSIDIAN_VAULT_PATH:-./obsidian-vault}:/workspace/obsidian-vault
```

This means:
- If `OBSIDIAN_VAULT_PATH` is set, your actual vault will be mounted
- If not set, it falls back to the local `./obsidian-vault` directory
- The mount is read-write, allowing the plugin to create and modify files

## Testing the Plugin

1. Build the plugin: `npm run build` in `/workspace/quickdraft`
2. Copy plugin files to the vault's `.obsidian/plugins/quickdraft/` directory
3. Enable the plugin in Obsidian settings
4. Test the Quick Draft functionality

## Troubleshooting

- **Permission Issues**: Ensure the `OBSIDIAN_VAULT_PATH` directory is accessible
- **Mount Not Working**: Verify the path in `.env` is correct and rebuild the container
- **Plugin Not Loading**: Check that all required files (manifest.json, main.js) are in the plugins directory