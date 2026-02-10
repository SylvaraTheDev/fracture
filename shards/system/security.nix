_:

{
  security = {
    sudo.enable = false;
    polkit.enable = true;
    run0.enableSudoAlias = true;

    # Cache polkit auth for wheel users for 5 minutes (AUTH_ADMIN_KEEP)
    # so successive run0 invocations don't re-prompt
    polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (subject.isInGroup("wheel") && subject.local && subject.active) {
          return polkit.Result.AUTH_ADMIN_KEEP;
        }
      });
    '';
  };
}
