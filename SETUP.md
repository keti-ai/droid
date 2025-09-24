# DROID Setup Guide

## Prerequisites

Before running the setup script, you need to set the following environment variables:

### Required Environment Variables

```bash
export DROID_SUDO_PASSWORD=your_sudo_password
export DROID_UBUNTU_PRO_TOKEN=your_ubuntu_pro_token
```

### Optional Environment Variables

```bash
export DROID_NUC_IP=172.16.0.5          # Default: 172.16.0.5
export DROID_ROBOT_IP=172.16.0.2        # Default: 172.16.0.2
export DROID_LAPTOP_IP=172.16.0.1       # Default: 172.16.0.1
```

## Setup Instructions

1. **Set environment variables:**
   ```bash
   # Copy the example file
   cp env.example .env
   
   # Edit .env with your actual values
   nano .env
   
   # Load environment variables
   source .env
   ```

2. **Run the setup script (securely pass env vars to sudo):**
   - Option A) Preserve current shell env in sudo
   ```bash
   sudo -E ./scripts/setup/nuc_setup.sh
   ```
   - Option B) Pass only required vars explicitly (recommended for CI/staging)
   ```bash
   sudo DROID_SUDO_PASSWORD="$DROID_SUDO_PASSWORD" \
        DROID_UBUNTU_PRO_TOKEN="$DROID_UBUNTU_PRO_TOKEN" \
        ./scripts/setup/nuc_setup.sh
   ```

## Security Notes

- Never commit `.env` files to version control
- The setup script will fail if required environment variables are not set
- All sensitive information is now stored in environment variables, not in code
- Prefer Option B above in shared/staging environments to minimize the env passed to root
