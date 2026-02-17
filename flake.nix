{
  description = "Nixos Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-ide.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-brave.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-ide,
    nixpkgs-brave,
    home-manager,
    ...
  } @ inputs: {
    nixosConfigurations = {
      poon-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit nixpkgs-unstable home-manager;};
        modules = [
          ./nixos/hosts/poon-nixos

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = ".backup";

            home-manager.users.poon = import ./nixos/hosts/poon-nixos/home.nix;

            home-manager.extraSpecialArgs = {inherit inputs;};
          }
        ];
      };
    };
  };
}
