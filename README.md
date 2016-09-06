# git-fiddle (1) [![Build Status](https://travis-ci.org/felixSchl/git-fiddle.svg?branch=master)](https://travis-ci.org/felixSchl/git-fiddle)

`git-fiddle` is a wrapper around `git-rebase(1)` that allows editing of commit
information straight from the `git-rebase` editor, such as the author date,
author name and commit message. This makes it trivial to edit a whole range
of commits, shift them through time or alter ownership.

## Installation

Simply ensure `git-fiddle` is in your `$PATH`. The `git fiddle` alias will
become available automatically.

## Usage

Usage is almost identical to that of `git-rebase`.

```usage
$ git fiddle -h
git-fiddle - edit commit meta information during an *interactive* rebase.

`git-fiddle(1)' is a lightweight wrapper around `git-rebase(1)' that
annotates each commit with it's *author* date, the author name, as well
as the commit message. Changes to any of these will then be applied
using an 'exec' script during the git-rebase sequence.

Usage:
  git fiddle [options] [args...]

Options:
  --[no-]fiddle
      Turn ON/OFF fiddeling. Useful to turn off all options and selectively
      enable some.
  --[no-]fiddle-author
      Do (not) edit author names. Note that the author *can* still be edited,
      but it is not pre-populated. [git config: fiddle.author]
  --[no-]fiddle-author-email
      Do not pre-populate the author's email. Refer to --[no-]fiddle-author.
      [git config: fiddle.author.email]
  --[no-]fiddle-author-date
      Do (not) edit author dates. Note that the author date *can* still be
      edited, but it is not pre-populated. [git config: fiddle.author.date]
  --[no-]fiddle-author-subject
      Do (not) commit subject lines. Note that the commit message *can* still
      be edited, but it is not pre-populated. [git config: fiddle.subject]
  --[no-]fiddle-author-body
      Do (not) the commit body. Note that the commit message *CANNOT* be edit
      if this option is turned OFF and might case `git-rebase` errors.
      [git config: fiddle.body]
  [args...] These arguments are passed verbatim to git-rebase.
```

## License

**git-fiddle** is released under the **MIT LICENSE**.
See file `LICENSE` for a more detailed description of its terms.
