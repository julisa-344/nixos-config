# NixOS Configuration Deployment Guide

This guide explains how to deploy the updated NixOS configuration with development environment support.

## 🚀 Quick Deployment

**On the NixOS system (Julisa's laptop):**

1. **Navigate to the config directory:**
   ```bash
   cd ~/nixos-config  # or wherever the config is located
   ```

2. **Pull the latest changes:**
   ```bash
   git pull origin main
   ```

3. **Run the deployment script:**
   ```bash
   ./deploy-nixos.sh
   ```

4. **Follow the prompts** and let the script handle everything!

## 📋 What the Deployment Script Does

The `deploy-nixos.sh` script will:

1. ✅ **Verify environment** - Checks you're on NixOS and in the right directory
2. ✅ **Create symlinks** - Sets up the proper module structure for home-manager
3. ✅ **Test configuration** - Builds the config to check for errors
4. ✅ **Apply changes** - Runs `nixos-rebuild switch` to deploy
5. ✅ **Verify tools** - Checks that essential tools are available
6. ✅ **Set permissions** - Makes development scripts executable

## 🔧 Manual Steps (if needed)

If the automatic script doesn't work, you can run these steps manually:

### 1. Fix Module Symlinks
```bash
cd ~/nixos-config
ln -sf dotfiles/home/modules users/julisa/modules
```

### 2. Test Configuration
```bash
sudo nixos-rebuild build --show-trace
```

### 3. Apply Configuration
```bash
sudo nixos-rebuild switch --show-trace
```

### 4. Set Permissions
```bash
chmod +x dev-environments/setup-project.sh
```

## 🎯 After Deployment

Once the deployment is complete:

1. **Log out and back in** to ensure all environment changes take effect

2. **Set up direnv in your shell** (if not already done):
   ```bash
   # For zsh (add to ~/.zshrc)
   eval "$(direnv hook zsh)"
   
   # For bash (add to ~/.bashrc)
   eval "$(direnv hook bash)"
   ```

3. **Test the development environment:**
   ```bash
   cd ~/nixos-config
   ./dev-environments/setup-project.sh test-project
   cd test-project
   direnv allow
   # You should see the development environment activate!
   ```

4. **Clean up test project:**
   ```bash
   cd ..
   rm -rf test-project
   ```

## 🛠️ Development Environment Usage

After successful deployment:

- **Create web dev project:** `./dev-environments/setup-project.sh my-web-app`
- **Create Python project:** `./dev-environments/setup-project.sh -t python-dev my-python-app`
- **Read full docs:** `cat dev-environments/README.md`

## 🆘 Troubleshooting

### Configuration Build Fails
- Check the error messages carefully
- Make sure all file paths are correct
- Verify the symlink exists: `ls -la users/julisa/modules`

### Tools Not Available After Deployment
- Log out and back in
- Check if direnv is properly configured in your shell
- Run `which direnv` to verify it's installed

### Permission Issues
- Make sure you're running as the correct user
- The script is designed for user 'julisa'
- You can run as root if needed

### Rollback if Needed
If something goes wrong, you can rollback:
```bash
sudo nixos-rebuild switch --rollback
```

## 📞 Getting Help

If you encounter issues:

1. Check the error messages in the script output
2. Look at NixOS logs: `journalctl -xe`
3. Verify file structure matches expected layout
4. Make sure all files are committed and pushed to git

## ✅ Success Indicators

After successful deployment, you should have:

- ✅ `nix --version` shows flakes support
- ✅ `direnv --version` works
- ✅ `docker --version` works (rootless)
- ✅ Development environment scripts are executable
- ✅ Home manager configuration loads without errors

---

**Ready to deploy? Run `./deploy-nixos.sh` on the NixOS system!** 🚀 