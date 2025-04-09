#!/bin/bash

# Display the ByteReaper banner
echo ""
echo "   ___          __         ___                              " | lolcat
echo "  / _ )  __ __ / /_ ___   / _ \ ___  ___ _   ___  ___   ____" | lolcat
echo " / _  | / // // __// -_) / , _// -_)/ _ \`/  / _ \/ -_) / __/" | lolcat
echo "/____/  \_, / \__/ \__/ /_/|_| \__/ \_,_/  / .__/\__/ /_/   " | lolcat
echo "       /___/                              /_/               " | lolcat
echo ""

# Random offensive security tip
quotes=("The supreme art of war is to subdue the enemy without fighting." "All warfare is based on deception." "He who knows when he can fight and when he cannot, will be victorious." "The whole secret lies in confusing the enemy, so that he cannot fathom our real intent." "To win one hundred victories in one hundred battles is not the acme of skill. To subdue the enemy without fighting is the acme of skill.")
random_quote=${quotes[$RANDOM % ${#quotes[@]}]}
echo "Offensive Security Tip: $random_quote" | lolcat
sleep 1
echo "☕ | ⚡ | ☯️" | lolcat
sleep 1

# Check internet connection
tput bold; echo "CHECKING IF YOU ARE CONNECTED TO THE INTERNET!" | lolcat
wget -q --spider https://google.com
if [ $? -ne 0 ]; then
    echo "++++ CONNECT TO THE INTERNET BEFORE RUNNING ByteReaper.sh!" | lolcat
    exit 1
fi
tput bold; echo "++++ CONNECTION FOUND, LET'S GO!" | lolcat

# Input domain and wordlist
read -p "Enter the domain: " domain
read -p "Enter path to wordlist: " wordlist

# Sanitize domain (strip protocol and slashes)
domain=$(echo "$domain" | sed 's/https\?:\/\///' | cut -d'/' -f1)

# Check wordlist
echo "Checking and Confirming your wordlist exist and proceeding with the attacks..." | lolcat
sleep 1
if [ ! -f "$wordlist" ]; then
    echo "Error: wordlist file $wordlist does not exist." | lolcat
    exit 1
fi

# Create output directory
mkdir -p "$domain"

# Run GoBuster
echo "Starting GoBuster with ACTIVE Scan against the target searching for specific extensions..." | lolcat
sleep 1
gobuster dir -u "https://www.$domain" -w "$wordlist" -x .js,.php,.yml,.env,.txt,.xml,.html,.config,.zip,.rar,.db,.sqlite,.sqlite3,.db3,.sql,.sqlitedb,.sdb,.sqlite2,.frm,.mdb,.accdb,.bak,.backup,.old,.sav,.save -t 30 -e -o "$domain/gobuster.txt"

# Extract 2xx/3xx URLs
echo "Extracting and filtering only 2xx & 3xx status codes..." | lolcat
grep -E "Status: (2[0-9]{2}|3[0-9]{2})" "$domain/gobuster.txt" | grep -oE "(http|https)://[a-zA-Z0-9./?=_-]*" | sort -u > "$domain/discovered_urls.txt"

# Fetch URLs from waybackurls (fixed pipeline)
echo "Fetching additional URLs from waybackurls with the same extensions as gobuster..." | lolcat
sleep 1
waybackurls "$domain" | grep -E "\.js$|\.php$|\.yml$|\.env$|\.txt$|\.xml$|\.config$|\.zip$|\.rar$|\.db$|\.sqlite$|\.sqlite3$|\.db3$|\.sql$|\.sqlitedb$|\.sdb$|\.sqlite2$|\.frm$|\.mdb$|\.accdb$|\.bak$|\.backup$|\.old$|\.sav$|\.save$" | sed -E "s#(https?://)?(www\.)?$domain#\1\2$domain#g" | sort -u | httpx -verbose -o "$domain/waybackurls.txt" 2>/dev/null | lolcat

# Fetch URLs from Wayback Machine CDX API
echo "Fetching more URLs from Wayback Machine CDX API..." | lolcat
sleep 1
curl -G "https://web.archive.org/cdx/search/cdx" --data-urlencode "url=*.$domain/*" --data-urlencode "collapse=urlkey" --data-urlencode "output=text" --data-urlencode "fl=original" > "$domain/curlresults.txt" 2>/dev/null || echo "Warning: Failed to fetch URLs from Wayback Machine CDX API." | lolcat

# Combine URLs
echo "Combining discovered URLs from gobuster, waybackurls, and CDX API..." | lolcat
sleep 1
cat "$domain/waybackurls.txt" "$domain/discovered_urls.txt" "$domain/curlresults.txt" 2>/dev/null | grep -E "\.js$|\.php$|\.yml$|\.env$|\.txt$|\.xml$|\.html$|\.config$|\.zip$|\.rar$|\.db$|\.sqlite$|\.sqlite3$|\.db3$|\.sql$|\.sqlitedb$|\.sdb$|\.sqlite2$|\.frm$|\.mdb$|\.accdb$|\.bak$|\.backup$|\.old$|\.sav$|\.save$" | sort -u > "$domain/discovered_urls.txt"

# Curl discovered URLs
echo "Performing curl on every URL I found to fetch the content..." | lolcat
sleep 1
while read -r url; do
    echo "Fetching content from $url..." | lolcat
    curl -vsS "$url" > "$domain/discovered_urls_for_$(echo "$url" | awk -F/ '{print $3}').txt" 2>&1
done < "$domain/discovered_urls.txt"

# Check SecretHub.json
if [ ! -f "SecretHub.json" ]; then
    echo "Error: SecretHub.json file not found." | lolcat
    exit 1
fi
if ! jq -e '.flags and .patterns' SecretHub.json >/dev/null 2>&1; then
    echo "Error: SecretHub.json is not properly formatted or missing required fields." | lolcat
    exit 1
fi

# Search for secrets
echo "I am now searching for secrets using SecretHub.json and saving the results in secrets.csv for you..." | lolcat
sleep 1
grep_flags=$(jq -r '.flags' SecretHub.json)
patterns=$(jq -r '.patterns | join("|")' SecretHub.json)
count=0
while read -r url; do
    file="$domain/discovered_urls_for_$(echo "$url" | awk -F/ '{print $3}').txt"
    if [ -f "$file" ]; then
        secrets=$(grep $grep_flags "$patterns" "$file" | awk '!seen[$0]++ { print $0 }')
        if [ -n "$secrets" ]; then
            echo "URL Affected: $url, Secret Found: $secrets" >> "$domain/secrets.csv"
            count=$((count + $(echo "$secrets" | wc -l)))
        fi
    fi
done < "$domain/discovered_urls.txt"
echo "Total secrets found: $count" >> "$domain/secrets.csv"

# Summary
echo "Scan & Analysis has completed! Results saved under $domain" | lolcat
echo "Total secrets found for $domain: $count" | lolcat

# Matrix effect
echo "Entering the Matrix for 5 seconds:" | toilet --metal -f term -F border 2>/dev/null || echo "Matrix effect skipped (toilet not installed)"
for ((i=0; i<5; i++)); do
    echo -ne "\033[0;31m10 \033[0;32m01 \033[1;33m11 \033[0;34m00 \033[0;35m01 \033[0;36m10 \033[1;37m00 \033[0;32m11 \033[0;35m01 \033[0;34m10 \033[1;33m11 \033[0;36m00\r"
    sleep 0.2
    echo -ne "\033[0;31m01 \033[0;32m10 \033[1;33m00 \033[0;34m11 \033[0;35m10 \033[0;36m01 \033[1;37m11 \033[0;32m00 \033[0;35m10 \033[0;34m01 \033[1;33m00 \033[0;36m11\r"
    sleep 0.2
done
echo ""
