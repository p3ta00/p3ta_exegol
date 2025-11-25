#!/bin/bash
# Monitor HTTP servers and netcat listeners for CTF shell catching

output=""

# Nerd Font icons (Python and PHP)
PY_ICON=$'\ue73c'
PHP_ICON=$'\ue73d'

# Check for HTTP servers (ONLY Python and PHP)
http_listeners=$(ss -tlnp 2>/dev/null | awk -v py="$PY_ICON" -v php="$PHP_ICON" '
    $4 ~ /:(80|443|8000|8080|8888|9000)$/ && $1 == "LISTEN" {
        split($4, addr, ":");
        port = addr[length(addr)];

        # ONLY show Python and PHP servers with Nerd Font icons
        if ($NF ~ /python/) proc = py;
        else if ($NF ~ /php/) proc = php;
        else proc = "";

        if (proc != "") print port ":" proc;
    }
' | sort -u)

# Check for netcat listeners (ONLY from Penelope)
nc_listeners=$(ss -tlnp 2>/dev/null | awk '
    $1 == "LISTEN" && ($NF ~ /nc|ncat|netcat/) {
        # Extract PID from the last field
        match($NF, /pid=([0-9]+)/, pid_match);
        if (pid_match[1]) {
            pid = pid_match[1];
            # Check if parent process is penelope
            cmd = "ps -o ppid= -p " pid " 2>/dev/null | xargs ps -o comm= -p 2>/dev/null";
            cmd | getline parent;
            close(cmd);

            # Also check if the process itself mentions penelope in cmdline
            cmd2 = "cat /proc/" pid "/cmdline 2>/dev/null | tr \"\\0\" \" \"";
            cmd2 | getline cmdline;
            close(cmd2);

            # Show listener if parent is penelope OR cmdline mentions penelope
            if (parent ~ /penelope/ || cmdline ~ /penelope/) {
                split($4, addr, ":");
                port = addr[length(addr)];
                print port;
            }
        }
    }
' | sort -u)

# Check for established reverse shells (ONLY for Python/PHP/Penelope listeners)
caught_shells=$(ss -tnp 2>/dev/null | awk '
    $1 == "ESTAB" && ($NF ~ /nc|ncat|netcat|python|php/) {
        # Extract PID to check if it belongs to our monitored listeners
        match($NF, /pid=([0-9]+)/, pid_match);
        if (pid_match[1]) {
            pid = pid_match[1];
            show = 0;

            # Check if it'\''s a python or php process
            if ($NF ~ /python|php/) {
                show = 1;
            }
            # Check if it'\''s a netcat spawned by penelope
            else if ($NF ~ /nc|ncat|netcat/) {
                cmd = "ps -o ppid= -p " pid " 2>/dev/null | xargs ps -o comm= -p 2>/dev/null";
                cmd | getline parent;
                close(cmd);

                cmd2 = "cat /proc/" pid "/cmdline 2>/dev/null | tr \"\\0\" \" \"";
                cmd2 | getline cmdline;
                close(cmd2);

                if (parent ~ /penelope/ || cmdline ~ /penelope/) {
                    show = 1;
                }
            }

            if (show) {
                split($5, remote, ":");
                remote_ip = remote[1];

                # Extract just the last octet or show partial IP for privacy
                split(remote_ip, octets, ".");
                if (length(octets) == 4) {
                    # Show last two octets for better identification
                    short_ip = octets[3] "." octets[4];
                } else {
                    short_ip = remote_ip;
                }

                # Try to identify shell type
                if ($NF ~ /bash/) shell = "bash";
                else if ($NF ~ /sh/) shell = "sh";
                else if ($NF ~ /zsh/) shell = "zsh";
                else shell = "shell";

                print short_ip ":" shell;
            }
        }
    }
' | sort -u | head -3)  # Limit to 3 to avoid cluttering

# Build output
if [ -n "$http_listeners" ]; then
    # Count and show first 2 HTTP servers
    http_count=$(echo "$http_listeners" | wc -l)
    http_display=$(echo "$http_listeners" | head -2 | tr '\n' ' ' | sed 's/ $//')
    if [ "$http_count" -gt 2 ]; then
        output="HTTP:$http_display+$((http_count-2))"
    else
        output="HTTP:$http_display"
    fi
fi

if [ -n "$nc_listeners" ]; then
    # Count and show first 2 nc listeners
    nc_count=$(echo "$nc_listeners" | wc -l)
    nc_display=$(echo "$nc_listeners" | head -2 | tr '\n' ',' | sed 's/,$//')
    if [ "$output" ]; then
        output="$output | "
    fi
    if [ "$nc_count" -gt 2 ]; then
        output="${output}LST:$nc_display+$((nc_count-2))"
    else
        output="${output}LST:$nc_display"
    fi
fi

if [ -n "$caught_shells" ]; then
    # Show caught shells
    shell_count=$(echo "$caught_shells" | wc -l)
    shell_display=$(echo "$caught_shells" | tr '\n' ' ' | sed 's/ $//')
    if [ "$output" ]; then
        output="$output | "
    fi
    if [ "$shell_count" -gt 0 ]; then
        output="${output}CAUGHT:$shell_display"
    fi
fi

# If nothing found, show idle status
if [ -z "$output" ]; then
    echo "idle"
else
    echo "$output"
fi
