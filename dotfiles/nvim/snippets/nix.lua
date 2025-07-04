local ls = require 'luasnip'
local s = ls.snippet
local i = ls.insert_node
local extras = require 'luasnip.extras'
local rep = extras.rep
local fmt = require('luasnip.extras.fmt').fmt


return {
    s("toggle_mod", fmt(
        [[
        {{
          lib,
          config,
          ...
        }}: {{
          options = {{
            {}.enable = lib.mkEnableOption "enable {}";
          }};
          config = lib.mkIf config.{}.enable {{
            {}
          }};
        }}
        ]], { i(1), rep(1), rep(1), i(2) }
    )),
    s("toggle_option", fmt(
        [[
        options = {{
          nixld.enable = lib.mkEnableOption "enable nixld";
        }};
        config = lib.mkIf config.nixld.enable {{
          {}
        }}
        ]], { i(1) }
    )),
    s("shell_nix", fmt(
        [[
        {{pkgs ? import <nixpkgs> {{}}}}:
        pkgs.mkShell {{
          buildInputs = with pkgs; [
            llvmPackages_19.clang-unwrapped
            llvmPackages_19.lld
            llvmPackages_19.llvm
            gcc
            # gcc-unwrapped
            glibc
            glibc.dev
            cmake
            libffi
            which
            cacert
            ocl-icd # OpenCL
            ninja
            cudaPackages.cudatoolkit
            cudaPackages.cuda_nvrtc
            cudaPackages.cuda_cudart
            cudaPackages.libcublas
            # cudaPackages.cudnn
            # cudaPackages.libcudnn
          ];

          shellHook = ''
            export SSL_CERT_FILE=${{pkgs.cacert}}/etc/ssl/certs/ca-bundle.crt
            unset NIX_ENFORCE_NO_NATIVE

            export LD_LIBRARY_PATH="${{pkgs.ocl-icd}}/lib:${{pkgs.llvmPackages_19.llvm}}/lib:${{pkgs.cudaPackages.cuda_nvrtc}}/lib:${{pkgs.cudaPackages.cudatoolkit}}/lib64:/run/opengl-driver/lib:$CUDA_PATH/lib:$CUDNN_PATH/lib:$LD_LIBRARY_PATH"
            export CC=clang
          '';
        }}
        ]], {}
    )),
    s("flake_nix", fmt(
        [[
        {{
          inputs = {{
            nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
          }};

          outputs = {{nixpkgs, ...}}:
          let
            system = "x86_64-linux";
            pkgs = nixpkgs.legacyPackages.${{system}};
          in {{
            devShells.${{system}}.default = pkgs.mkShell {{
              packages = [
                pkgs.python311
                pkgs.python311Packages.torch
              ];
              shellHook = ''
                echo 'welcome'
              '';
            }};
          }};
        }}
        ]], {}
    )),
}
