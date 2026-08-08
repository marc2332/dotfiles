def --env gittd [name: string] {
    let main_branch = "main"

    let line = (git worktree list --verbose | lines | where ($it | str contains $main_branch) | first)

    if $line != "" {
        let path = ($line | split row " " | first)
        cd $path
        print $"☄️ Switching to main branch."
    } else {
        print $"No worktree found for branch ($main_branch)"
    }
    git worktree remove -f $name
    git branch -D $name
    print $"🧹 Deleted "($name)" branch and worktree."
}

def --env gittm [] {
    let main_branch = "main"

    let line = (git worktree list --verbose | lines | where ($it | str contains $main_branch) | first)

    if $line != "" {
        let path = ($line | split row " " | first)
        print $"☄️ Switching to main branch."
        cd $path
    } else {
        print $"No worktree found for branch ($main_branch)"
    }
}

def --env gittn [name: string] {
    let dirname = ($name | str replace "/" "-")
    let dir = $"../($dirname)"

    if (git branch --list $name | is-empty) {
        print $"🎯 Creating ($name)"
        git worktree add -b $name $dir

        print $"⚡️ Moving to ($name)"
        cd $dir

        print $"🔧 Updating submodules"
        git submodule update --init --recursive

        print $"✅ ($name) is ready."
    } else {
        if not ($dir | path exists) {
            print $"⚡️ Attaching worktree ($name)"
            git worktree add $dir $name

            cd $dir

            print $"🔧 Updating submodules"
            git submodule update --init --recursive
        } else {
            print $"⚡️ Switching to existing worktree ($name)"
            cd $dir
        }

        print $"✅ ($name) is ready."
    }
}

def --env gittc [num: int] {
    let name = $"pr-($num)"
    let dirname = ($name | str replace "/" "-")
    let dir = $"../($dirname)"

    if not ($dir | path exists) {
        print $"🎯 Checking ($name)"
        git worktree add -b $name $dir

        print $"⚡️ Moving to ($name)"
        cd $dir

        print $"🚀 Fetching PR ($num)"
        gh pr checkout $num

        print $"🔧 Updating submodules"
        git submodule update --init --recursive

        print $"✅ ($name) is ready."
    }

    print $"⚡️ Switching to existing worktree ($name)"
    cd $dir
}



alias gitt = git worktree list
alias gitbranch = git switch
alias gitbranchnew = git switch -c
alias gita = git add -A
alias gitc = git commit -m
alias gitpull = git pull origin $"(git branch --show-current)"
alias gitpush = git push origin $"(git branch --show-current)"

alias hh = cd $env.HOME
alias pp = cd $"($env.HOME)/Projects"

export-env {
    $env.PROMPT_COMMAND = { ||
        let cwd = if ($env.PWD | str starts-with $nu.home-dir) {
            $env.PWD | str replace $nu.home-dir "~"
        } else {
            $env.PWD
        }
        let name = $env.USERNAME
        let branch = do { git branch --show-current } | complete
        let git_status = if $branch.exit_code == 0 and $branch.stdout != "" {
            $"(ansi white) ➜(ansi aqua) \u{eafe} ($branch.stdout)"
        } else {
            "\n"
        }
        $"(ansi green)($name) (ansi white)➜ (ansi yellow)($cwd)($git_status)"
    }

    $env.PROMPT_COMMAND_RIGHT = { ||
        ""
    }

    $env.PROMPT_INDICATOR = {||
        $"(ansi white)➜ "
    }
}
