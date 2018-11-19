proc demo(alpha=1, verb=0, junk= @[ "rs", "tu" ], stuff= @[ "ab", "cd" ],
          args: seq[string]): int=
  ## demo entry point with varied, meaningless parameters.  A Nim invocation
  ## might be: demo(alpha=2, @[ "hi", "ho" ]) corresponding to the command
  ## invocation "demo --alpha=2 hi ho" (assuming executable gets named demo).
  echo "alpha:", alpha, " verb:", verb, " junk:", repr(junk), " stuff:", repr(stuff)
  for i, arg in args: echo "positional[", i, "]: ", repr(arg)
  return 42

when isMainModule:
  from strutils import split, `%`, join, strip
  from cligen/argcvt import ArgcvtParams, argKeys, argDf, ERR  # Little helpers
  from parseutils import parseInt

  proc argParse*(dst: var int, dfl: int; a: var ArgcvtParams): bool =
    if a.parNm == "verb":               # make "verb" a special kind of int
      inc(dst)                          # that just counts its occurances
    else:
      if parseInt(strip(a.val), dst) == 0:
        ERR("Bad value: \"$1\" for option \"$2\"; expecting int\n$3" %
               [ a.val, a.key, a.help ])
        return false
    return true

  proc argHelp*(defVal: int, a: var ArgcvtParams): seq[string] =
    if a.parNm == "verb":    # This is a parNm-conditional hybrid of bool & int
      result = @[ a.argKeys, "countr", a.argDf($defVal) ]
      if a.parSh.len > 0: a.shortNoVal.incl(a.parSh[0])
      a.longNoVal.add(a.parNm)
    else:
      result = @[ a.argKeys, "int", a.argDf($defVal) ]

  import cligen
  dispatch(demo)
