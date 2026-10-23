# SRD Monochrome — fish colours and prompt
# Install as ~/.config/fish/conf.d/srd-monochrome.fish. Settings in config.fish run after conf.d,
# so remove any fish_color_* lines or fish_prompt function there.
# Commands are bold white, arguments soft white, the rest the kitty greys; errors are reverse video.

set -g fish_color_command ffffff --bold
set -g fish_color_keyword ffffff --bold
set -g fish_color_param e6e6e6
set -g fish_color_option bcbcbc
set -g fish_color_quote bcbcbc
set -g fish_color_operator ffffff
set -g fish_color_escape bcbcbc
set -g fish_color_redirection 8a8a8a
set -g fish_color_end 8a8a8a
set -g fish_color_error 000000 --background=e6e6e6
set -g fish_color_comment 767676 --italics
set -g fish_color_autosuggestion 767676
set -g fish_color_valid_path --underline
set -g fish_color_cwd e6e6e6
set -g fish_color_user 8a8a8a
set -g fish_color_host 8a8a8a
set -g fish_color_cancel 767676
set -g fish_color_selection 000000 --background=e6e6e6
set -g fish_color_search_match --background=3a3a3a
set -g fish_pager_color_prefix ffffff --bold --underline
set -g fish_pager_color_completion e6e6e6
set -g fish_pager_color_description 8a8a8a
set -g fish_pager_color_progress 000000 --background=e6e6e6
set -g fish_pager_color_selected_background --background=3a3a3a

# user@host and git in grey, directory in soft white, the prompt sign white (reverse after a failure).
function fish_prompt
    set -l last_status $status
    set_color 8a8a8a
    echo -n $USER'@'(prompt_hostname)' '
    set_color e6e6e6
    echo -n (prompt_pwd)
    set_color 8a8a8a
    fish_vcs_prompt
    if test $last_status -ne 0
        set_color 000000 --background=e6e6e6
        echo -n ' '$last_status' >'
        set_color normal
        echo -n ' '
    else
        set_color ffffff --bold
        echo -n ' > '
    end
    set_color normal
end
