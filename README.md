# LOVR Override Test for lamdera/containers

This repo demonstrates testing new modules (BiSeqDict, MultiSeqDict, MultiBiSeqDict) added to `lamdera/containers` using the LOVR override mechanism.

## Setup

1. The `overrides/packages/lamdera/containers/1.0.0` folder contains the modified containers package with the new modules
2. Run `./override.sh` to package it and generate the override metadata
3. Run the app with: `LDEBUG=1 EXPERIMENTAL=1 LOVR=~/path/to/qwertytrewq/overrides lamdera make src/Frontend.elm src/Backend.elm`

## Issue

The new exposed modules (BiSeqDict, MultiSeqDict, MultiBiSeqDict) are listed in the overridden `elm.json` but cannot be imported in the app. Getting "MODULE NOT FOUND" errors.

Related PR: https://github.com/lamdera/containers/pull/1
