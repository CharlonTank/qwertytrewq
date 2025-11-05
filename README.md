# LOVR Override Test for lamdera/containers

✅ **Successfully testing new modules (BiSeqDict, MultiSeqDict, MultiBiSeqDict) added to `lamdera/containers` using the LOVR override mechanism!**

## Setup

Use Dillon's improved script (requires jq):

```bash
./override-dillon.sh /path/to/containers
```

This will automatically:
1. Copy the package files
2. Build the override
3. Generate pack.zip and endpoint.json
4. Clean caches
5. Start lamdera live with the override

**Bug Fix:** The original script had a bug in endpoint.json URL generation - it was missing the author part of the package name. Fixed in this repo's version.

## Manual Testing

To compile without starting lamdera live:

```bash
LDEBUG=1 EXPERIMENTAL=1 LOVR=/path/to/qwertytrewq/overrides lamdera make src/Backend.elm
```

## Result

✅ BiSeqDict, MultiSeqDict, and MultiBiSeqDict are now importable and compile successfully!

Related PR: https://github.com/lamdera/containers/pull/1
