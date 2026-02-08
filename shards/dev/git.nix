{ config, ... }:

let
  inherit (config.fracture) user;
in
{
  home-manager.users.${user.login} = _: {
    programs.git = {
      enable = true;
      settings = {
        user.name = user.git.name;
        user.email = user.git.email;
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
        fetch.prune = true;
        rerere.enabled = true;
        core.autocrlf = "input";
        ghq.root = "/projects";
      };
    };

    programs.gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };

    home.persistence."/persist".directories = [
      ".config/gh"
    ];
  };
}
