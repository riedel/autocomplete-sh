{
  description = "AutoComplete.sh - LLM Powered Bash/Zsh Completion";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux =
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; };
      in
      {
        default = pkgs.runCommand "autocomplete-sh" {
          buildInputs = [ pkgs.jq pkgs.bc pkgs.curl ];
        } ''
          mkdir -p $out/bin

          cp ${./autocomplete.sh} $out/bin/autocomplete.sh
          cp ${./autocomplete.zsh} $out/bin/autocomplete.zsh
          chmod +x $out/bin/autocomplete.sh $out/bin/autocomplete.zsh
        '';
      };

    devShells.x86_64-linux.default = let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      autocomplete = self.packages.x86_64-linux.default;
    in
      pkgs.mkShell {
        buildInputs = [
          pkgs.zsh
          pkgs.jq
          pkgs.bc
          pkgs.curl
          autocomplete
        ];
        shellHook = ''
          export PATH="${autocomplete}/bin:$PATH"
          export BASH_COMPLETION_DIR="${autocomplete}/share/bash-completions/completions"
          export fpath=("${autocomplete}/share/zsh/site-functions" $fpath)
          source /usr/share/bash-completion/bash_completion 2>/dev/null || true
          source "${autocomplete}/bin/autocomplete.sh" enable 2>/dev/null || true
        '';
      };
  };
}
