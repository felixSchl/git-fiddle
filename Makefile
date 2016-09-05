.DEFAULT: test

test:
	bats tests

watch:
	fswatch git-fiddle _fiddle_seq_editor tests/*.bats tests/*.bash | \
		xargs -I{} -n1 make test

