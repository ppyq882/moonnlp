///|
test "demo report contains deterministic public API markers" {
  let report = report()
  assert_true(report.contains("MoonNLP demo report"))
  assert_true(report.contains("tokens="))
  assert_true(report.contains("keywords="))
  assert_true(report.contains("summary="))
  assert_true(report.contains("classification="))
}
