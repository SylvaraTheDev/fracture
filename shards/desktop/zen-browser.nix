{ config, inputs, ... }:

let
  inherit (config.fracture.user) login;

  # Extension install URLs
  amo = id: "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";
in
{
  home-manager.users.${login} =
    { ... }:
    {
      imports = [ inputs.zen-browser.homeModules.twilight ];
      programs.zen-browser = {
        enable = true;
        policies = {
          ExtensionSettings = {
            # Ghostery
            "firefox@ghostery.com" = {
              install_url = amo "ghostery";
              installation_mode = "force_installed";
            };
            # Bitwarden
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              install_url = amo "bitwarden-password-manager";
              installation_mode = "force_installed";
            };
            # Dark Reader
            "addon@darkreader.org" = {
              install_url = amo "darkreader";
              installation_mode = "force_installed";
            };
            # Port Authority
            "{6c00218c-707a-4977-84cf-36df1cef310f}" = {
              install_url = amo "port-authority";
              installation_mode = "force_installed";
            };
            # YouTube Auto HD
            "avi6106@gmail.com" = {
              install_url = amo "youtube-auto-hd-fps";
              installation_mode = "force_installed";
            };
            # SponsorBlock
            "sponsorBlocker@ajay.app" = {
              install_url = amo "sponsorblock";
              installation_mode = "force_installed";
            };
            # Return YouTube Dislike
            "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
              install_url = amo "return-youtube-dislikes";
              installation_mode = "force_installed";
            };
            # Remove YouTube Shorts
            "{2766e9f7-7bf2-4c72-81b9-d119eb54c753}" = {
              install_url = amo "remove-youtube-shorts";
              installation_mode = "force_installed";
            };
            # Chameleon
            "{3579f63b-d8ee-424f-bbb6-6d0ce3285e6a}" = {
              install_url = amo "chameleon-ext";
              installation_mode = "force_installed";
            };
            # LocalCDN
            "{b86e4813-687a-43e6-ab65-0bde4ab75758}" = {
              install_url = amo "localcdn-fork-of-decentraleyes";
              installation_mode = "force_installed";
            };
            # ClearURLs
            "{74145f27-f039-47ce-a470-a662b129930a}" = {
              install_url = amo "clearurls";
              installation_mode = "force_installed";
            };
            # CanvasBlocker
            "CanvasBlocker@kkapsner.de" = {
              install_url = amo "canvasblocker";
              installation_mode = "force_installed";
            };
            # Skip Redirect
            "skipredirect@sblask" = {
              install_url = amo "skip-redirect";
              installation_mode = "force_installed";
            };
          };
        };
      };

      home.persistence."/persist".directories = [
        ".zen"
      ];
    };
}
