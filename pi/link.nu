# Link the Pi configuration managed by this dotfiles repository.
# Existing files are moved to a .bak file before they are replaced.

def link-managed [source: path, target: path] {
    let source = ($source | path expand)
    let target = ($target | path expand)
    let parent = ($target | path dirname)

    if not ($source | path exists) {
        print $"Skipping ($source): source does not exist"
        return
    }

    mkdir $parent

    # readlink succeeds only when the target is already a symbolic link.
    let link = (do { ^readlink $target } | complete)
    if $link.exit_code == 0 {
        let current = ($link.stdout | str trim | path expand)
        if $current == $source {
            print $"Already linked: ($target)"
            return
        }
        rm $target
    } else if ($target | path exists) {
        let backup = $"($target).bak"
        if ($backup | path exists) {
            print $"Not replacing ($target): backup already exists at ($backup)"
            return
        }
        mv $target $backup
        print $"Backed up ($target) to ($backup)"
    }

    ^ln -s $source $target
    print $"Linked ($target) -> ($source)"
}

let pi_config = ($env.FILE_PWD | path expand)
let repo = ($pi_config | path dirname)
let pi_dir = ($env.HOME | path join ".pi" "agent")

link-managed ($pi_config | path join "settings.json") ($pi_dir | path join "settings.json")
link-managed ($pi_config | path join "extensions") ($pi_dir | path join "extensions")
link-managed ($repo | path join ".claude" "skills" "tidyup") ($pi_dir | path join "skills" "tidyup")
