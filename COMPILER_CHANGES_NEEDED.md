# Lamdera Compiler Changes Needed for BiSeqDict, MultiSeqDict, MultiBiSeqDict

## Problem

The Lamdera compiler has hardcoded support for `SeqDict` and `SeqSet` from `lamdera/containers`, but not for the new `BiSeqDict`, `MultiSeqDict`, and `MultiBiSeqDict` types.

When these types are used in `BackendModel`, the compiler generates `w3_encode_*` and `w3_decode_*` wrappers with incorrect signatures.

## Root Cause

The codec generation is pattern-matched on specific module and type names. The compiler needs to be updated to recognize the three new types.

## Files That Need Changes

### 1. `extra/Lamdera/Wire3/Helpers.hs`

**Add module constants** (after line 760):

```haskell
mLamdera_SeqDict = (Module.Canonical (Name "lamdera" "containers") "SeqDict")
mLamdera_SeqSet = (Module.Canonical (Name "lamdera" "containers") "SeqSet")
-- ADD THESE THREE:
mLamdera_BiSeqDict = (Module.Canonical (Name "lamdera" "containers") "BiSeqDict")
mLamdera_MultiSeqDict = (Module.Canonical (Name "lamdera" "containers") "MultiSeqDict")
mLamdera_MultiBiSeqDict = (Module.Canonical (Name "lamdera" "containers") "MultiBiSeqDict")
```

**Add to unwrapAliasesDeep** (after line 799):

```haskell
TType (Module.Canonical (Name "lamdera" "containers") "SeqDict") "SeqDict" [key, val] ->
  TType (Module.Canonical (Name "lamdera" "containers") "SeqDict") "SeqDict" [unwrapAliasesDeep key, unwrapAliasesDeep val]

-- ADD THESE THREE:
TType (Module.Canonical (Name "lamdera" "containers") "BiSeqDict") "BiSeqDict" [key, val] ->
  TType (Module.Canonical (Name "lamdera" "containers") "BiSeqDict") "BiSeqDict" [unwrapAliasesDeep key, unwrapAliasesDeep val]

TType (Module.Canonical (Name "lamdera" "containers") "MultiSeqDict") "MultiSeqDict" [key, val] ->
  TType (Module.Canonical (Name "lamdera" "containers") "MultiSeqDict") "MultiSeqDict" [unwrapAliasesDeep key, unwrapAliasesDeep val]

TType (Module.Canonical (Name "lamdera" "containers") "MultiBiSeqDict") "MultiBiSeqDict" [key, val] ->
  TType (Module.Canonical (Name "lamdera" "containers") "MultiBiSeqDict") "MultiBiSeqDict" [unwrapAliasesDeep key, unwrapAliasesDeep val]
```

### 2. `extra/Lamdera/Wire3/Encoder.hs`

**Add to encoderForType** (after line 179):

```haskell
TType (Module.Canonical (Name "lamdera" "containers") "SeqDict") "SeqDict" [key, value] ->
  (a (VarForeign mLamdera_SeqDict "encodeDict" ...))

-- ADD THESE THREE:
TType (Module.Canonical (Name "lamdera" "containers") "BiSeqDict") "BiSeqDict" [key, value] ->
  (a (VarForeign mLamdera_BiSeqDict "encodeBiSeqDict"
        (Forall
           (Map.fromList [("key", ()), ("value", ())])
           (TLambda
              (TLambda (TVar "key") tLamdera_Wire_Encoder)
              (TLambda (TLambda (TVar "value") tLamdera_Wire_Encoder)
                 (TLambda
                    (TType mLamdera_BiSeqDict "BiSeqDict" [TVar "key", TVar "value"])
                    tLamdera_Wire_Encoder))))))

TType (Module.Canonical (Name "lamdera" "containers") "MultiSeqDict") "MultiSeqDict" [key, value] ->
  (a (VarForeign mLamdera_MultiSeqDict "encodeMultiSeqDict"
        (Forall
           (Map.fromList [("key", ()), ("value", ())])
           (TLambda
              (TLambda (TVar "key") tLamdera_Wire_Encoder)
              (TLambda (TLambda (TVar "value") tLamdera_Wire_Encoder)
                 (TLambda
                    (TType mLamdera_MultiSeqDict "MultiSeqDict" [TVar "key", TVar "value"])
                    tLamdera_Wire_Encoder))))))

TType (Module.Canonical (Name "lamdera" "containers") "MultiBiSeqDict") "MultiBiSeqDict" [key, value] ->
  (a (VarForeign mLamdera_MultiBiSeqDict "encodeMultiBiSeqDict"
        (Forall
           (Map.fromList [("key", ()), ("value", ())])
           (TLambda
              (TLambda (TVar "key") tLamdera_Wire_Encoder)
              (TLambda (TLambda (TVar "value") tLamdera_Wire_Encoder)
                 (TLambda
                    (TType mLamdera_MultiBiSeqDict "MultiBiSeqDict" [TVar "key", TVar "value"])
                    tLamdera_Wire_Encoder))))))
```

**Add to deepEncoderForType (first occurrence)** (after line 308):

```haskell
TType (Module.Canonical (Name "lamdera" "containers") "SeqDict") "SeqDict" [key, val] ->
  call (encoderForType depth ifaces cname tipe) [ deepEncoderForType depth ifaces cname key, deepEncoderForType depth ifaces cname val ]

-- ADD THESE THREE:
TType (Module.Canonical (Name "lamdera" "containers") "BiSeqDict") "BiSeqDict" [key, val] ->
  call (encoderForType depth ifaces cname tipe) [ deepEncoderForType depth ifaces cname key, deepEncoderForType depth ifaces cname val ]

TType (Module.Canonical (Name "lamdera" "containers") "MultiSeqDict") "MultiSeqDict" [key, val] ->
  call (encoderForType depth ifaces cname tipe) [ deepEncoderForType depth ifaces cname key, deepEncoderForType depth ifaces cname val ]

TType (Module.Canonical (Name "lamdera" "containers") "MultiBiSeqDict") "MultiBiSeqDict" [key, val] ->
  call (encoderForType depth ifaces cname tipe) [ deepEncoderForType depth ifaces cname key, deepEncoderForType depth ifaces cname val ]
```

**Add to deepEncoderForType (second occurrence with value)** (after line 403):

```haskell
TType (Module.Canonical (Name "lamdera" "containers") "SeqDict") "SeqDict" [key, val] ->
  call (encoderForType depth ifaces cname tipe) [ deepEncoderForType depth ifaces cname key, deepEncoderForType depth ifaces cname val, value ]

-- ADD THESE THREE:
TType (Module.Canonical (Name "lamdera" "containers") "BiSeqDict") "BiSeqDict" [key, val] ->
  call (encoderForType depth ifaces cname tipe) [ deepEncoderForType depth ifaces cname key, deepEncoderForType depth ifaces cname val, value ]

TType (Module.Canonical (Name "lamdera" "containers") "MultiSeqDict") "MultiSeqDict" [key, val] ->
  call (encoderForType depth ifaces cname tipe) [ deepEncoderForType depth ifaces cname key, deepEncoderForType depth ifaces cname val, value ]

TType (Module.Canonical (Name "lamdera" "containers") "MultiBiSeqDict") "MultiBiSeqDict" [key, val] ->
  call (encoderForType depth ifaces cname tipe) [ deepEncoderForType depth ifaces cname key, deepEncoderForType depth ifaces cname val, value ]
```

### 3. `extra/Lamdera/Wire3/Decoder.hs`

**Add to decoderForType** (after line ~338, similar to SeqDict pattern):

```haskell
TType (Module.Canonical (Name "lamdera" "containers") "BiSeqDict") "BiSeqDict" [key, val] ->
    (a (Call
          (a (VarForeign mLamdera_BiSeqDict "decodeBiSeqDict"
                (Forall
                   (Map.fromList [("k", ()), ("value", ())])
                   (TLambda
                      (TAlias
                         mLamdera_Wire
                         "Decoder"
                         [("a", TVar "k")]
                         (Filled
                            (TType
                               (Module.Canonical (Name "elm" "bytes") "Bytes.Decode")
                               "Decoder"
                               [TVar "k"])))
                      (TLambda
                         (TAlias
                            mLamdera_Wire
                            "Decoder"
                            [("a", TVar "value")]
                            (Filled
                               (TType
                                  (Module.Canonical (Name "elm" "bytes") "Bytes.Decode")
                                  "Decoder"
                                  [TVar "value"])))
                         (TAlias
                            mLamdera_Wire
                            "Decoder"
                            [ ( "a"
                              , TType
                                  mLamdera_BiSeqDict
                                  "BiSeqDict"
                                  [TVar "k", TVar "value"])
                            ]
                            (Filled
                               (TType
                                  (Module.Canonical (Name "elm" "bytes") "Bytes.Decode")
                                  "Decoder"
                                  [ TType
                                      mLamdera_BiSeqDict
                                      "BiSeqDict"
                                      [TVar "k", TVar "value"]
                                  ]))))))))
          [deepDecoderForType depth ifaces cname key, deepDecoderForType depth ifaces cname val]))

-- Similar for MultiSeqDict and MultiBiSeqDict
```

### 4. `extra/Lamdera/TypeHash.hs`

**Add pattern matches** (after line ~347):

```haskell
("lamdera", "containers", "SeqDict", "SeqDict") ->
  case tvarResolvedParams of
    key:value:_ -> ...

-- ADD THESE THREE:
("lamdera", "containers", "BiSeqDict", "BiSeqDict") ->
  case tvarResolvedParams of
    key:value:_ ->
      DHash $ (BS8.pack "BiSeqDict_") <> dhash key <> (BS8.pack "_") <> dhash value
    _ ->
      DError "❗️impossible !2 param BiSeqDict type"

("lamdera", "containers", "MultiSeqDict", "MultiSeqDict") ->
  case tvarResolvedParams of
    key:value:_ ->
      DHash $ (BS8.pack "MultiSeqDict_") <> dhash key <> (BS8.pack "_") <> dhash value
    _ ->
      DError "❗️impossible !2 param MultiSeqDict type"

("lamdera", "containers", "MultiBiSeqDict", "MultiBiSeqDict") ->
  case tvarResolvedParams of
    key:value:_ ->
      DHash $ (BS8.pack "MultiBiSeqDict_") <> dhash key <> (BS8.pack "_") <> dhash value
    _ ->
      DError "❗️impossible !2 param MultiBiSeqDict type"
```

### 5. `extra/Lamdera/Evergreen/MigrationGenerator.hs`

**Add migration helpers** (after line ~1002):

```haskell
("lamdera", "containers", "SeqDict", "SeqDict") -> migrate2ParamCollection ...

-- ADD THESE THREE:
("lamdera", "containers", "BiSeqDict", "BiSeqDict") -> migrate2ParamCollection
  (\m_p0      -> T.concat [ "BiSeqDict.toList |> List.map (Tuple.mapFirst ", m_p0, ") |> BiSeqDict.fromList" ])
  (\m_p1      -> T.concat [ "BiSeqDict.map (\\k -> ", m_p1, ")" ])
  (\m_p0 m_p1 -> T.concat [ "BiSeqDict.toList |> List.map (Tuple.mapBoth (", m_p0, ") (", m_p1, ")) |> BiSeqDict.fromList" ])

("lamdera", "containers", "MultiSeqDict", "MultiSeqDict") -> migrate2ParamCollection
  (\m_p0      -> T.concat [ "MultiSeqDict.toList |> List.map (Tuple.mapFirst ", m_p0, ") |> MultiSeqDict.fromList" ])
  (\m_p1      -> T.concat [ "MultiSeqDict.map (\\k -> ", m_p1, ")" ])
  (\m_p0 m_p1 -> T.concat [ "MultiSeqDict.toList |> List.map (Tuple.mapBoth (", m_p0, ") (", m_p1, ")) |> MultiSeqDict.fromList" ])

("lamdera", "containers", "MultiBiSeqDict", "MultiBiSeqDict") -> migrate2ParamCollection
  (\m_p0      -> T.concat [ "MultiBiSeqDict.toList |> List.map (Tuple.mapFirst ", m_p0, ") |> MultiBiSeqDict.fromList" ])
  (\m_p1      -> T.concat [ "MultiBiSeqDict.map (\\k -> ", m_p1, ")" ])
  (\m_p0 m_p1 -> T.concat [ "MultiBiSeqDict.toList |> List.map (Tuple.mapBoth (", m_p0, ") (", m_p1, ")) |> MultiBiSeqDict.fromList" ])
```

## Testing

After making these changes:

1. Rebuild the Lamdera compiler
2. Test with the qwertytrewq repo:
   ```bash
   cd /path/to/qwertytrewq
   ./override-dillon.sh /path/to/containers
   ```

The compilation should succeed with MultiBiSeqDict in BackendModel.

## Notes

- All three new types follow the same pattern as SeqDict (2-parameter types with key/value)
- The encoder/decoder function names in the modules are:
  - `encodeBiSeqDict` / `decodeBiSeqDict`
  - `encodeMultiSeqDict` / `decodeMultiSeqDict`
  - `encodeMultiBiSeqDict` / `decodeMultiBiSeqDict`
