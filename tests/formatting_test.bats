#!/usr/bin/env bats

load test_helper
load ../scripts/formatting.sh

@test "bold wraps the text" {
  run bold "text"

  [ "$status" -eq 0 ]
  [ "$output" = $'\e[1mtext\e[0m' ]
}

@test "italic wraps the text" {
  run italic "text"

  [ "$output" = $'\e[3mtext\e[0m' ]
}

@test "underline wraps the text" {
  run underline "text"

  [ "$output" = $'\e[4mtext\e[0m' ]
}

@test "strikethrough wraps the text" {
  run strikethrough "text"

  [ "$output" = $'\e[9mtext\e[0m' ]
}

@test "format with color" {
  run format -c red "text"

  [ "$status" -eq 0 ]
  [ "$output" = $'\e[0;31mtext\e[0;0m' ]
}

@test "format with type" {
  run format -t bold "text"

  [ "$output" = $'\e[0;1mtext\e[0;0m' ]
}

@test "format with color and type using long flags" {
  run format --color cyan --type underline "text"

  [ "$output" = $'\e[4;36mtext\e[0;0m' ]
}

@test "format maps every color" {
  local -A colors=([black]=30 [red]=31 [green]=32 [yellow]=33 [blue]=34 [magenta]=35 [cyan]=36 [white]=37)

  for color in "${!colors[@]}"; do
    run format -c "$color" "text"
    [ "$output" = $'\e[0;'"${colors[$color]}"$'mtext\e[0;0m' ]
  done
}

@test "format maps every type" {
  local -A types=([bold]=1 [bright]=1 [fade]=2 [italic]=3 [underline]=4 [blink]=5 [inverse]=7 [strikethrough]=9)

  for type in "${!types[@]}"; do
    run format -c red -t "$type" "text"
    [ "$output" = $'\e['"${types[$type]}"$';31mtext\e[0;0m' ]
  done
}

@test "format with unknown color falls back to reset" {
  run format -c pink "text"

  [ "$output" = $'\e[0;0mtext\e[0;0m' ]
}

@test "format with a single text does not add a newline" {
  format_with_marker() {
    format "text"
    echo "|"
  }

  run format_with_marker

  [ "$output" = $'\e[0;0mtext\e[0;0m|' ]
}

@test "format with multiple texts prints one per line" {
  run format -c green "first" "second"

  [ "$output" = $'\e[0;32mfirst\nsecond\n\e[0;0m' ]
}

@test "format with reset color and type" {
  run format -c reset -t reset "text"

  [ "$output" = $'\e[0;0mtext\e[0;0m' ]
}

@test "format without text prints only the style" {
  run format -c red -t bold

  [ "$status" -eq 0 ]
  [ "$output" = $'\e[1;31m' ]
}

@test "format prints text that looks like a flag or has backslashes as it is" {
  run format "-n"
  [ "$output" = $'\e[0;0m-n\e[0;0m' ]

  run format 'C:\temp'
  [ "$output" = $'\e[0;0mC:\\temp\e[0;0m' ]
}

@test "bold prints backslashes as they are" {
  run bold 'C:\temp'

  [ "$output" = $'\e[1mC:\\temp\e[0m' ]
}

@test "format with a flag but no value ends, and resets" {
  # Without errexit, a failed `shift 2` used to loop forever
  run_clean timeout 5 bash -c '. scripts/formatting.sh; set +e; format text -c'

  [ "$status" -eq 0 ]
  [ "$output" = $'\e[0;0mtext\e[0;0m' ]
}
