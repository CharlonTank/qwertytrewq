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

✅ BiSeqDict, MultiSeqDict, and MultiBiSeqDict are now importable!

⚠️ **Codec Generation Issue**: There's a Lamdera compiler issue with automatic codec wrapper generation for these new types.

### The Problem

When using these types in `BackendModel` (see `src/Types.elm`):

```elm
type alias BackendModel =
    { message : String
    , chatDocuments : MultiBiSeqDict ChatId DocumentId
    , documents : List Document
    }
```

The compiler generates `w3_encode_*` and `w3_decode_*` wrappers with incorrect signatures:

```
-- TOO MANY ARGS ------------------------------------------------- src/Types.elm

The `w3_decode_MultiBiSeqDict` value is not a function, but it was given 2 arguments.
The `w3_encode_MultiBiSeqDict` function expects 1 argument, but it got 3 instead.
```

### What's Implemented

The encoder/decoder functions in the modules ARE implemented correctly (following SeqDict/SeqSet pattern):

- `encodeMultiBiSeqDict : (key -> Encoder) -> (value -> Encoder) -> MultiBiSeqDict key value -> Encoder`
- `decodeMultiBiSeqDict : Decoder k -> Decoder value -> Decoder (MultiBiSeqDict k value)`

But the compiler's automatic wrapper generation produces incorrect signatures.

### Demo Code

`src/Backend.elm` contains a complete working demo with:
- Opaque ID types (`ChatId`, `DocumentId`)
- Fake S3 document generation
- Helper functions: `getDocumentsInChat`, `getChatsWithDocument`, `transferDocument`
- Example many-to-many chat ↔ documents relationship

Related PR: https://github.com/lamdera/containers/pull/1
