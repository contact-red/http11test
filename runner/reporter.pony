actor Reporter
  """
  Receives one result per test by RFC Test ID and prints a single line per
  outcome, then a summary line ("N pass / M fail / K skip") once every
  expected test has reported. Sets the process exit code non-zero when any
  test fails so CI can detect regressions without parsing output.

  Future versions will group by RFC section and emit coverage stats.
  """
  let _env: Env
  let _total: USize
  var _pass: USize = 0
  var _fail: USize = 0
  var _skip: USize = 0

  new create(env: Env, total: USize) =>
    _env = env
    _total = total

  be pass(test_id: String) =>
    _env.out.print("PASS " + test_id)
    _pass = _pass + 1
    _maybe_summarize()

  be fail(test_id: String, reason: String) =>
    _env.out.print("FAIL " + test_id + ": " + reason)
    _fail = _fail + 1
    _env.exitcode(1)
    _maybe_summarize()

  be skip(test_id: String, reason: String) =>
    _env.out.print("SKIP " + test_id + ": " + reason)
    _skip = _skip + 1
    _maybe_summarize()

  fun ref _maybe_summarize() =>
    if (_pass + _fail + _skip) == _total then
      _env.out.print("--- " + _pass.string()
        + " pass / " + _fail.string()
        + " fail / " + _skip.string() + " skip ---")
    end
