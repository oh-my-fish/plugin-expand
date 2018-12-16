<img src="https://cdn.combinatronics.com/oh-my-fish/oh-my-fish/e4f1c2e0219a17e2c748b824004c8d0b38055c16/docs/logo.svg" align="left" height="160px"/>

### expand
Word expansion for [Oh My Fish!][omf].

[![MIT License][license-badge]](/LICENSE)

<br/>


## Overview
This plugin provides the means of adding word-by-word expansions for other plugins, as well as for your own expansions. A word expansion is a real-time substitution of the words you type on the command line. It is a bit like `abbr`, but dynamic and extensible and a whole lot more awesome.


[![asciicast](https://asciinema.org/a/39860.png)](https://asciinema.org/a/39860)


## Install
```fish
$ omf install expand
```


## Using it
Using expansions already provided by your installed plugins couldn't be any easier. Word expansions are triggered when you use the <kbd>TAB</kbd> key when the cursor is over a word. Before checking for regular command completions, the current word will be checked against available word expansions. If a suitable expansion is found, the current word will be replaced with the result of the expansion.

If more than one suitable expansion is found for the current word, `expand` will attempt to use an _interactive filter_ tool to allow you to choose interactively which expansion you would like to use (or none if you don't want any of them). By default, `expand` will use the filter command specified in the `$FILTER` environment variable. If a filter is not specified, `expand` will look for some popular ones if you have them installed:

- [fzf]: A command-line fuzzy finder written in Go.
- [peco]: The simplistic interactive filtering tool, written in Go.
- [percol]: An interactive grep tool written in Python.
- [selecta]: A fuzzy text selector written in Ruby.

If no filters are specified or installed, you can still cycle through all of the available replacements by pressing <kbd>TAB</kbd> repeatedly.

If you decide that you want to cancel the current expansion, you can press <kbd>Backspace</kbd> to undo the expansion.

Expansions can be more than simple abbreviations; the current word can be used to introduce patterns and queries to provide dynamic expansions in real-time.


## Writing expansions
Writing your own expansions is incredibly simple. There are two parts to a word expansion: a condition, and an expander. A condition is the means of specifying on what words your expander should be run. The expander is a script or function that takes the current word and produces a replacement as its output. Below is a simple but useful example that lets you expand a substitution syntax (like `s/something/something else`) into the previous command with the substitution applied:

```fish
expand-word -p '^s/..*/.*$' -e 'echo -n "$history[1]" | sed -e (commandline -t)/g'
```

And that's really all that you need! Try running the above command, and then try pressing the tab key on a substitution:

```fish
$ git stats
git: 'stats' is not a git command. See 'git --help'.

Did you mean this?
        status
$ s/stats/status<Tab>
$ git status
```

The `expand-word` function registers a new expander by specifying the condition and the expander itself as option arguments. There are two interesting flags used in this expansion: `-p` and `-e`. First let's look at what `-e` is doing. This flag is short for the `--expander` option, which specifies the expander function or script to run. The expander uses the builtin [`commandline`][commandline] command to print the current _token_, or word, that is being expanded and uses it as a substitution expression with `sed`. The replaced command is then printed out, and the output is used by `expand` to replace the current word.

You can do pretty much anything you like in an expander. All you are required to do is print the desired replacement for the current word to standard output, and `expand` will do the rest. Now let's look closer at how we can use conditions to properly choose when our expander should run.


### Conditions
There are two different types of conditions currently available: patterns, or functions.

A pattern condition is an [extended regular expression][regex] that is matched against the current word. If the word matches, the corresponding expander is used. Let's look at how we can use a pattern to run an expander on words that start with `git`:

```fish
expand-word -p '^git.+' -e 'some_expander_function'
```

The `^git.+` pattern will match any word that starts with `git`, but not `git` itself. Keep in mind that the regular expression format is the POSIX ERE syntax, not PCRE. Check the `grep` manual for a good guide to this syntax.

The second type of condition is more interesting; a function condition is a script or function that is run each time you attempt to expand a word. The function can perform any logic you need to perform in order to correctly determine if your expander can expand the current word. If the word is of a format that your expander is expecting, your function should return `0` to tell `expand` to use your expander. If the function cannot expand the given word, a non-zero value should be returned instead, and expander will be skipped.

For performance reasons, you may want to put some effort into optimizing a condition function, since _all_ of the condition functions will run every time you expand a word. If you have a lot of expansions or slow conditions, you may experience some lag when expanding words.

Below is an example of using a function as an expansion condition:

```fish
function should_expand_home
  if test (commandline -t) != "home" -a "$PWD" != "$HOME"
    return 1
  end
end

expand-word -c 'should_expand_home' -e 'echo $HOME'
```

This expansion will only be used on the word "home", but only if you are not currently in your home directory. Pretty cool, eh?


### Giving up
In addition to conditions, you can also have your expanders "give up" prematurely when trying to expand a word by returning a non-zero exit code. If your expander gives up a word, it will be ignored and the next expander will be used as normal.


## License
[MIT][mit] © [Stephen Coakley][author] et [al][contributors]


[author]: https://github.com/coderstephen
[commandline]: http://fishshell.com/docs/current/commands.html#commandline
[completions]: http://fishshell.com/docs/current/tutorial.html#tut_tab_completions
[contributors]: https://github.com/oh-my-fish/plugin-fasd/graphs/contributors
[fzf]: https://github.com/junegunn/fzf
[license-badge]: https://img.shields.io/badge/license-MIT-007EC7.svg?style=flat-square
[mit]: http://opensource.org/licenses/MIT
[omf]: https://www.github.com/oh-my-fish/oh-my-fish
[peco]: https://github.com/peco/peco
[percol]: https://github.com/mooz/percol
[regex]: http://pubs.opengroup.org/onlinepubs/009696899/basedefs/xbd_chap09.html
[selecta]: https://github.com/garybernhardt/selecta
