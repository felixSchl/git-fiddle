#!/usr/bin/env bats

load support

function init_repo () {
	git init
	git config user.name  'Foo Bar'
	git config user.email 'foo@bar.com'
	touch .gitgnore && git add -A && git commit -m 'Initial commit'
}

@test "fiddle: change commit messages" {
	init_repo &> /dev/null

	touch A && git add -A && git commit -m "$(cat <<-'EOF'
		Commit A

		This is the first commit.
		In a series of commits
	EOF
	)" &> /dev/null

	GIT_SEQUENCE_EDITOR="$(mk_script <<-'EOF'
		#!/bin/sh
		sed -i.bak -e 's/Commit A/Commit B/g' "$1"
	EOF
	)" run git_fiddle HEAD~
	[ $status -eq 0 ]

	run git show -s HEAD $'--format=%s\n\n%b'
	[ $status -eq 0 ]
	[[ $output == "$(cat <<-'EOF'
		Commit B

		This is the first commit.
		In a series of commits
	EOF
	)" ]]
}

@test "fiddle: change multiple commit messages" {
	init_repo &> /dev/null

	touch A && git add -A && git commit -m "$(cat <<-'EOF'
		Commit A

		This is the first commit.
		In a series of commits
	EOF
	)" &> /dev/null

	touch B && git add -A && git commit -m "$(cat <<-'EOF'
		Commit B

		This is the second commit.
	EOF
	)" &> /dev/null

	GIT_SEQUENCE_EDITOR="$(mk_script <<-'EOF'
		#!/bin/sh
		sed -i.bak \
			-e 's/Commit A/Commit Z/g' \
			-e 's/Commit B/Commit Y/g' \
			"$1"
	EOF
	)" run git_fiddle HEAD~2
	[ $status -eq 0 ]

	run git show -s HEAD~ $'--format=%s\n\n%b'
	[ $status -eq 0 ]
	[[ $output == "$(cat <<-'EOF'
		Commit Z

		This is the first commit.
		In a series of commits
	EOF
	)" ]]

	run git show -s HEAD $'--format=%s\n\n%b'
	[ $status -eq 0 ]
	[[ $output == "$(cat <<-'EOF'
		Commit Y

		This is the second commit.
	EOF
	)" ]]
}

@test "fiddle: --no-messages" {
	init_repo &> /dev/null

	touch A && git add -A && git commit -m "$(cat <<-'EOF'
		Commit A

		This is the first commit.
		In a series of commits
	EOF
	)" &> /dev/null

	GIT_SEQUENCE_EDITOR="$(mk_script <<-EOF
		#!/bin/sh
		cat "\$1" > "$PWD/todo-contents"
		sed -i.bak -e 's/Commit A/Commit B/g' "\$1"
	EOF
	)" run git_fiddle --no-messages HEAD~
	[ $status -eq 0 ]

	# count the expected lines: 1 action and no messages => 1 line
	output="$(git stripspace --strip-comments < todo-contents | wc -l)"
	[[ "$output" == 1 ]]

	run git show -s HEAD --format='%s'
	[ $status -eq 0 ]
	[[ $output == 'Commit A' ]]
}

@test "fiddle: change commit author" {
	init_repo &> /dev/null

	touch A && git add -A && git commit -m 'Commit A' &> /dev/null

	GIT_SEQUENCE_EDITOR="$(mk_script <<-'EOF'
		#!/bin/sh
		sed -i.bak -e 's/by: .*/by: Quz Baz <quz@baz.com>/g' "$1"
	EOF
	)" run git_fiddle HEAD~
	[ $status -eq 0 ]

	run git show -s HEAD --format='%an <%ae>'
	[ $status -eq 0 ]
	[[ "$output" == "Quz Baz <quz@baz.com>" ]]
}

@test "fiddle: change commit author date" {
	init_repo &> /dev/null

	local -r before='Wed Aug 17 15:47:08 2016 +1200'
	local -r expected='Sun Dec 24 12:00:08 1989 +1200'

	touch A && git add -A && {
		GIT_AUTHOR_DATE="$before" git commit -m 'Commit A' --date="$before"
	} &> /dev/null

	run git show -s HEAD --format='%ad'
	[ $status -eq 0 ]
	[[ $output == "$before" ]]

	GIT_SEQUENCE_EDITOR="$(mk_script <<-EOF
		#!/bin/sh
		sed -i.bak -e 's/$before/$expected/g' "\$1"
	EOF
	)" run git_fiddle HEAD~
	[ $status -eq 0 ]

	run git show -s HEAD --format='%ad'
	[ $status -eq 0 ]
	[[ "$output" == "$expected" ]]
}
