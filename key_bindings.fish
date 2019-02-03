if status --is-interactive
  # Bind word expansion (and command completion) to the Tab key.
  bind --sets-mode expand \t expand:execute

  # During expansion, bind Backspace to revert the operation.
  bind --mode expand --sets-mode default --key backspace expand:revert

  # Bind Tab to cycle through the available expansions.
  bind --mode expand \t expand:choose-next

  # If the user enters any key other than Backspace, exit expand mode and passthrough keys to the default binding.
  bind --mode expand --sets-mode default '' ''
end
