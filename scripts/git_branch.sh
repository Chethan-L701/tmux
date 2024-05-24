uc=false
mc=false
tc=false

# this a script to show git branch name
untracked() {
    local val=$(git -C "$1" ls-files --others --exclude-standard 2>/dev/null | wc -l)
    if [ "$val" -gt 0 ]; then
        echo "#[fg=colour203,bg=default,bold]$val"
        uc=true
    else
        echo ""
    fi
}
get_git_status() {
    local dir="$1"
    local untracked=$(git -C "$dir" ls-files --others --exclude-standard 2>/dev/null | wc -l)
    local added=$(git -C "$dir" diff --name-only --cached 2>/dev/null | wc -l)
    local modified=$(git -C "$dir" diff --name-only 2>/dev/null | wc -l)

    local upstream_count=$(git -C "$dir" rev-list --count --left-right @{upstream}...HEAD 2>/dev/null | cut -f2)
    local downstream_count=$(git -C "$dir" rev-list --count --left-right HEAD...@{upstream} 2>/dev/null | cut -f2)

    local status_info=""

    if [ "$untracked" -gt 0 ]; then
        status_info+="#[fg=colour203,bg=default,bold] $untracked"
    fi

    if [ "$modified" -gt 0 ]; then
        status_info+="#[fg=colour221,bg=default,bold]  $modified"
    fi

    if [ "$added" -gt 0 ]; then
        status_info+="#[fg=colour78,bg=default,bold]  $added"
    fi

    if [ "$upstream_count" -gt 0 ]; then
        status_info+="#[fg=colour117,bg=default,bold] ↑$upstream_count"
    fi

    if [ "$downstream_count" -gt 0 ]; then
        status_info+="#[fg=colour117,bg=default,bold] ↓$downstream_count"
    fi

    echo "$status_info"
}
dir="$(tmux display-message -p -F "#{pane_current_path}")"
current_dir="$dir"

close() {
    local status_info="$1"
    if ["$status_info" -eq ""]; then
        echo ""
    else
        echo "#[fg=colour99,bg=default,bold] "
    fi
}

while [ "$current_dir" != "/" ]; do
    if [ -d "$current_dir/.git" ] || [ -f "$current_dir/.git" ]; then
        branch=$(git -C "$current_dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
        if [ -n "$branch" ]; then
            status_info=$(get_git_status "$current_dir")
            echo " #[fg=colour99,bg=default,bold] $branch #[fg=colour99,bg=default,bold]$status_info$(close $status_info)"
        else
            echo ""
        fi
        exit 0
    fi
    current_dir=$(dirname "$current_dir")
done

echo ""

