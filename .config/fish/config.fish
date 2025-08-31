bind \cf zi # bind control + f to zi (zoxide)

set -gx EDITOR micro
set -gx MICRO_TRUECOLOR 1

starship init fish | source
fzf --fish | source
zoxide init fish | source
fastfetch
if status is-interactive
    # Commands to run in interactive sessions can go here
end
