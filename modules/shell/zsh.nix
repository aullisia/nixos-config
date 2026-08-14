{ den, ... }:
{
  den.aspects.zsh = {
    nixos =
      { ... }:
      {
        programs.zsh.enable = true;
        environment.pathsToLink = [ "/share/zsh" ];
      };

    homeManager =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      let
        c = config.lib.stylix.colors;
      in
      {
        programs.zsh = {
          enable = true;

          history = {
            size = 10000;
            save = 10000;
            extended = true;
            share = true;
            ignoreDups = true;
            ignoreSpace = true;
            expireDuplicatesFirst = true;
          };

          historySubstringSearch.enable = true;

          autosuggestion.enable = true;
          enableCompletion = true;

          antidote = {
            enable = true;
            plugins = [
              "Aloxaf/fzf-tab"
              "zdharma-continuum/fast-syntax-highlighting"
              "ohmyzsh/ohmyzsh path:plugins/colored-man-pages"
              "zsh-users/zsh-completions"
              "jeffreytse/zsh-vi-mode kind:defer"
            ];
          };

          sessionVariables = {
            FZF_DEFAULT_OPTS = "--color=fg:#${c.base05},bg:#${c.base00},hl:#${c.base0B} --color=fg+:#${c.base05},bg+:#${c.base01},hl+:#${c.base0B} --color=info:#${c.base0A},prompt:#${c.base0C},pointer:#${c.base0D} --color=marker:#${c.base0D},spinner:#${c.base0A},header:#${c.base03} --height 80% --layout reverse --border";
          };

          shellAliases = {
            ls = "lsd";
            la = "lsd -a";
            ll = "lsd -la";
            cat = "bat";
            ff = "fastfetch";
            cls = "clear";
          };

          setOptions = [
            "HIST_REDUCE_BLANKS"
            "HIST_VERIFY"
            "HIST_FIND_NO_DUPS"
            "HIST_SAVE_NO_DUPS"
          ];

          initContent = lib.mkBefore ''
            zmodload zsh/nearcolor
            ZVM_INIT_MODE=sourcing

            zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
            zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
            zstyle ':completion:*' menu no
            zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd $realpath'
            zstyle ':fzf-tab:*' fzf-command fzf

            function zvm_after_lazy_keybindings_setup() {
              bindkey '^I' fzf-tab-complete
            }

            autoload -Uz compinit
            compinit

            if (( $+functions[enable-fzf-tab] )); then
              enable-fzf-tab
            fi
          '';
        };

        programs.starship = {
          enable = true;
          enableZshIntegration = true;
          settings = {
            add_newline = false;
            format = "$directory$git_branch$git_status$character";

            directory = {
              style = "bold cyan";
              truncation_length = 3;
              truncate_to_repo = true;
            };

            character = {
              success_symbol = "[➜](bold green)";
              error_symbol = "[➜](bold red)";
            };
          };
        };
      };
  };
}