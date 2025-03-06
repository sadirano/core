# Noir Core Utility Scripts

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Noir Core Utility Scripts is a collection of lightweight Windows batch scripts designed to streamline common administrative tasks without relying on external packages (except for [Scoop](https://scoop.sh/) when needed). These scripts are ideal for quickly enhancing your workflow on any Windows machine.

## Features

- **adm**: Elevates privileges to allow administrative tasks.
- **env**: Opens the Windows Environment Variables in Administrative mode.
- **h**: Puts your system into hibernation.
- **restart**: Safely restarts Windows Explorer by stopping it, waiting for input, and then restoring it.

## Installation

### Prerequisites
- Windows operating system.
- [Scoop](https://scoop.sh/) (optional): The scripts can be installed via a Scoop bucket for easier management.

### Manual Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/sadirano/core.git
   ```

2. **Navigate to the Repository Directory**
   ```bash
   cd core
   ```

3. **Run the Scripts**
   - For example, to elevate privileges:
     ```bash
     adm.cmd
     ```
   - Ensure your system's execution policy permits running batch scripts.

### Installation via Scoop

A Scoop manifest will be available in the [bucket repository](https://github.com/sadirano/bucket.git). Once added, you can install Noir Core Utility Scripts using:
```bash
scoop bucket add sadirano https://github.com/sadirano/bucket.git
scoop install core
```

## Usage Examples via Win+R

You can quickly launch these scripts using the Windows Run dialog:

### Elevate Privileges with `adm`
1. Press **Win + R**.
2. Type `adm` (or `adm.cmd` if required) and press **Enter**.
3. Follow the on-screen instructions.

### Restart Windows Explorer with `restart`
1. Press **Win + R**.
2. Type `restart` (or `restart.cmd` if required) and press **Enter**.
3. The script will terminate Explorer, wait for your input, and then restart it.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.