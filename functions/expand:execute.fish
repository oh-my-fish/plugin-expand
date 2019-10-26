function expand:execute -d 'Executes word expansion on the current token'
  # Record the current unexpanded command string.
  commandline | read -g __expand_last_string

  # Reset the replacements for this session.
  set -g __expand_replacements

  # Iterate available expansions for one that matches the current token.
  for expansion in $__expand_expanders
    set -l expansion (echo $expansion)

    # Check if the expansion condition matches the token.
    if eval "$expansion[1]" > /dev/null
      # If the expansion matches, execute the expander and use its output as replacements.
      if set -l replacements (eval "$expansion[2]" | sed '/^\s*$/d')
        set __expand_replacements $__expand_replacements $replacements
      end
    end
  end

  # If no replacements are available for the current token, defer to regular completion.
  if not set -q __expand_replacements[1]
    set -l ver (string split "." $FISH_VERSION)
    if test (count $ver) -gt 0 -a $ver[1] -lt 3
        # not fish 3, preserve fish 2 behavior
        commandline -f complete
    else if commandline --paging-mode
        # the completion menu has been shown
        commandline -f down-line
    else
        # show the completion menu
        commandline -f complete down-line
    end
    return
  end

  # Set a default filter list if none is specified.
  set -q FILTER
    or set -l FILTER percol peco fzf selecta

  # Choose the filter to use for this session ahead of time for performance.
  set -e __expand_filter
  for filter in $FILTER
    if type -q $filter
      set -g __expand_filter $filter
    end
  end

  # Choose a replacement from the ones now defined.
  expand:choose-next
end
