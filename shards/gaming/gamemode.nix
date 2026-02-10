{
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
        softrealtime = "auto";
        inhibit_screensaver = 0;
        ioprio = 0;
      };

      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        nv_powermizer_mode = 1;
      };

      cpu = {
        park_cores = "no";
        pin_cores = "yes";
      };

      custom = {
        start = "notify-send 'GameMode' 'Performance mode ON'";
        end = "notify-send 'GameMode' 'Performance mode OFF'";
      };
    };
  };
}
