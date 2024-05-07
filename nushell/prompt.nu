
export-env {
$env.PROMPT_COMMAND = { ||
    let cwd = $env.PWD | path basename 
    let name = $env.USERNAME
    let branch = do { git branch --show-current } | complete
    let git_status = if $branch.exit_code == 0 and $branch.stdout != "" {
        $"(ansi white) ➜(ansi aqua) \u{eafe} ($branch.stdout)"
    } else {
        "\n"
    }
    $"(ansi yellow)($name) (ansi white)➜ (ansi green)($cwd)($git_status)\n"
}

$env.PROMPT_COMMAND_RIGHT = { ||
    ""
}

}


