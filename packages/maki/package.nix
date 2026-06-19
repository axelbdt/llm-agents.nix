{
  lib,
  fetchFromGitHub,
  rustPlatform,
  stdenv,
  openssl,
  perl,
  pkg-config,
  python3,
  versionCheckHook,
  versionCheckHomeHook,
}:

rustPlatform.buildRustPackage rec {
  pname = "maki";
  version = "0.3.18";

  src = fetchFromGitHub {
    owner = "tontinton";
    repo = "maki";
    tag = "v${version}";
    hash = "sha256-YZbdAkPFrCEZ1vPLnhjFgIM5wU0FTa3+LUcBz4mTswc=";
  };

  cargoHash = "sha256-uXCnFmXLQw7vKyJ7Z4TQuUeA3tfJH89fljVfru4d1CY=";

  cargoBuildFlags = [
    "--package"
    pname
  ];

  nativeBuildInputs = [
    pkg-config
    perl
    python3
  ];

  buildInputs = [ openssl ];

  # Upstream monty includes a relative README path that does not survive Nix
  # vendoring. Remove this once monty stops including the relative path.
  postPatch = ''
    for f in "$cargoDepsCopy"/monty-*/src/lib.rs "$cargoDepsCopy"/source-git-*/monty-*/src/lib.rs; do
      if [ -e "$f" ]; then
        substituteInPlace "$f" \
          --replace-fail '#![doc = include_str!("../../../README.md")]' \
                         '#![doc = "Monty Python bridge."]'
      fi
    done
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 target/${stdenv.hostPlatform.rust.rustcTarget}/release/maki \
      $out/bin/maki

    runHook postInstall
  '';

  # Tests may require network access, provider credentials, or writable config.
  doCheck = false;

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
    versionCheckHomeHook
  ];

  passthru.category = "AI Coding Agents";

  meta = with lib; {
    description = "Efficient AI coding agent with a native Rust TUI";
    homepage = "https://maki.sh";
    changelog = "https://github.com/tontinton/maki/releases/tag/v${version}";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ fromSource ];
    mainProgram = "maki";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
