<div align="center">
  <img src="https://github.com/user-attachments/assets/7382d026-7dfa-43f6-acfa-bcb42262e244" alt="ByteReaper" width="200"/>
  <h1>ByteReaper</h1>
  <p>A powerful reconnaissance tool for offensive security testing, automating directory enumeration, historical URL discovery, and sensitive information detection.</p>
</div>

  [![GitHub stars](https://img.shields.io/github/stars/manojxshrestha/ByteReaper)](https://github.com/manojxshrestha/ByteReaper/stargazers)
  [![GitHub forks](https://img.shields.io/github/forks/manojxshrestha/ByteReaper)](https://github.com/manojxshrestha/ByteReaper/network)

## Overview

**ByteReaper** is a Bash-based reconnaissance tool developed for offensive security enthusiasts and bug hunters. It automates directory and file enumeration, scrapes historical URLs, and hunts for sensitive data leaks on target domains. Leveraging tools like `gobuster`, `waybackurls`, and the Wayback Machine CDX API, it’s built to uncover hidden attack surfaces fast.

> **Warning**: This tool is for educational purposes and authorized security testing only. Use it responsibly and only on targets you have explicit permission to scan.

## Features

- **Directory Enumeration**: Uses `gobuster` to brute-force directories and files with a customizable wordlist and extension set.
- **Historical URL Discovery**: Pulls archived URLs from `waybackurls` and the Wayback Machine CDX API.
- **Sensitive Data Detection**: Scans fetched content for secrets using patterns defined in `SecretHub.json`.
- **Pretty Output**: Colorized with `lolcat` and a Matrix-style flourish because recon should look cool.
- **Robust Design**: Handles missing tools gracefully and adapts to tricky server responses.

## Getting Started

- **Required Tools**:
  - `bash`, `wget`, `grep`, `sed`, `awk`, `curl` (usually pre-installed)
  - `gobuster`: Directory enumeration engine
  - `waybackurls`: Historical URL scraper
  - `httpx`: URL validator
  - `jq`: JSON parser for `SecretHub.json`
  - `lolcat`: Output colorizer
  - `toilet`: Matrix effect
- **Go**: Needed to install `gobuster`, `waybackurls`, and `httpx` if not already present.

## Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/manojshrestha/ByteReaper.git
   cd ByteReaper
   ```

2. **Install Dependencies**:
   - Install Go:
     ```bash
     sudo apt install golang  # Debian/Ubuntu
     ```
   - Install tools:
     ```bash
     go install github.com/OJ/gobuster/v3@latest
     go install github.com/tomnomnom/waybackurls@latest
     go install github.com/projectdiscovery/httpx/cmd/httpx@latest
     sudo apt install jq lolcat toilet  # Optional, for full experience
     ```
   - Add Go bin to PATH:
     ```bash
     echo 'export PATH=$PATH:~/go/bin' >> ~/.bashrc && source ~/.bashrc
     ```

3. **Set Permissions**:
   ```bash
   chmod +x ByteReaper.sh
   ```

## Usage

1. **Prepare**:
   - Provide a wordlist (e.g., `/home/pwn/directory-list-2.3-medium.txt`).

2. **Run the Tool**:
   ```bash
   ./ByteReaper.sh
   ```
   - Enter the target domain (e.g., `example.com`).
   - Enter the path to your wordlist.

3. **Output**:
   - Results are saved in a folder named after the domain (e.g., `example.com/`).
   - Key files: `gobuster.txt`, `discovered_urls.txt`, `secrets.csv`.

## SecretHub.json Format

Create a `SecretHub.json` file in the script directory to define patterns for sensitive data:
```json
{
  "flags": "-i",
  "patterns": [
    "api_key=[A-Za-z0-9_-]+",
    "password=[^\\s]+",
    "AWS_ACCESS_KEY_ID=[A-Za-z0-9]{20}"
  ]
}
```
- `flags`: `grep` flags (e.g., `-i` for case-insensitive).
- `patterns`: Regex patterns to match secrets.

## Example

```bash
$ ./ByteReaper.sh
Enter the domain: example.com
Enter path to wordlist: /home/user/directory-list-2.3-medium.txt
```

Output will include enumerated directories, historical URLs, and any secrets found in `example.com/secrets.csv`.

## Disclaimer

ByteReaper is for authorized testing only. Unauthorized use may violate laws or terms of service.
