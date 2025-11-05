# Test Repository for lamdera/containers New Types

✅ **Successfully testing BiSeqDict, MultiSeqDict, and MultiBiSeqDict with full compiler support!**

This repository demonstrates the three new container types added to `lamdera/containers` and verifies that the Lamdera compiler correctly generates Wire3 codecs for them.

## Related PRs

- **Container types**: [lamdera/containers#1](https://github.com/lamdera/containers/pull/1)
- **Compiler support**: [lamdera/compiler#69](https://github.com/lamdera/compiler/pull/69)

Both PRs are required for the new types to work in Lamdera apps.

## Setup

Use the improved override script (requires jq):

```bash
./override-dillon.sh /path/to/containers
```

This automatically:
1. Copies package files
2. Builds the override
3. Generates pack.zip and endpoint.json
4. Cleans caches
5. Starts lamdera live with the override

**Bug Fix**: Fixed endpoint.json URL generation bug (was missing author name).

## Testing with Modified Compiler

To test with the compiler changes from [lamdera/compiler#69](https://github.com/lamdera/compiler/pull/69):

```bash
# Build modified compiler
cd /path/to/lamdera-compiler
stack install

# Test compilation
cd /path/to/qwertytrewq
LDEBUG=1 EXPERIMENTAL=1 LOVR="$(pwd)/overrides" lamdera make src/Backend.elm
```

## Results

✅ **All three types work perfectly with proper compiler support!**

### Before Compiler Fix
```
-- TOO MANY ARGS ------------------------------------------------- src/Types.elm

The `w3_decode_MultiBiSeqDict` value is not a function, but it was given 2 arguments.
The `w3_encode_MultiBiSeqDict` function expects 1 argument, but it got 3 instead.
```

### After Compiler Fix
```
Success! Compiled 4 modules.
```

## Demo Code

`src/Backend.elm` demonstrates real-world usage:
- Opaque ID types using the `Id a` pattern (ChatId, DocumentId)
- Many-to-many relationship: chats ↔ documents
- Helper functions: `getDocumentsInChat`, `getChatsWithDocument`, `transferDocument`
- Example operations showing bidirectional queries

```elm
type alias BackendModel =
    { message : String
    , chatDocuments : MultiBiSeqDict (Id ChatId) (Id DocumentId)
    , documents : List Document
    }
```

The implementation shows how these types work with opaque types (not limited to `comparable`) and demonstrates efficient bidirectional lookups for many-to-many relationships.
