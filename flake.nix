{
  description = "Nixos Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-dev.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-claude.url = "github:nixos/nixpkgs/7fb694b30a1edae368bb0a0710c561af8970924b";
    nixpkgs-brave.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-productivity.url = "github:nixos/nixpkgs/nixos-unstable";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprpaper.url = "github:hyprwm/hyprpaper";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-dev,
    nixpkgs-claude,
    nixpkgs-brave,
    nixpkgs-productivity,
    home-manager,
    hyprland,
    hyprpaper,
    ...
  } @ inputs: {
    nixosConfigurations = {
      poon-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit nixpkgs-unstable home-manager;};
        modules = [
          ./nixos/hosts/poon-nixos

          hyprland.nixosModules.default

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";

            home-manager.users.poon = import ./nixos/hosts/poon-nixos/home.nix;

            home-manager.extraSpecialArgs = {inherit inputs;};
          }
        ];
      };
    };
  };
}
