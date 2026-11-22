#!/bin/sh
# Generates JUnit XML files shaped like cloudbees/unify-mcp-server's integration-test reports
# (many files, each test case carrying a large <system-out> execution trace).
# usage: gen-junit.sh <outdir> <files> <cases_per_file> <stdout_kb_per_case>
set -eu
out=$1; files=$2; cases=$3; kb=$4
mkdir -p "$out"
line='2026-11-03T08:40:00Z INFO agent response: {"tool":"list_components","status":"ok","result":"lorem ipsum dolor sit amet"}'
n=$(( kb * 1024 / ${#line} + 1 ))
i=0
while [ "$i" -lt "$files" ]; do
  f="$out/junit-gemini-suite$i.xml"
  {
    echo '<?xml version="1.0" encoding="UTF-8"?>'
    echo "<testsuites><testsuite name=\"suite$i [gemini]\" tests=\"$cases\" failures=\"0\" errors=\"0\" skipped=\"0\" time=\"1.0\">"
    j=0
    while [ "$j" -lt "$cases" ]; do
      echo "<testcase name=\"test_${i}_${j}\" classname=\"suite$i\" time=\"0.5\"><system-out><![CDATA["
      k=0
      while [ "$k" -lt "$n" ]; do echo "$line"; k=$((k + 1)); done
      echo "]]></system-out></testcase>"
      j=$((j + 1))
    done
    echo "</testsuite></testsuites>"
  } > "$f"
  i=$((i + 1))
done
echo "Generated $files files x $cases cases x ~${kb}KB stdout:"
echo "  total XML size: $(cat "$out"/*.xml | wc -c) bytes"
echo "  test cases:     $(cat "$out"/*.xml | grep -c '<testcase')"
