{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # Local AI (System)
  services.ollama.enable = true;
}
