.DEFAULT: test

test:
	bats -p tests

watch:
	fswatch -x git-fiddle _fiddle_seq_editor tests/*.bats tests/*.bash 2>/dev/null | \
		while read -r f attr; do \
			if ! [ -z "$$f" ] && [[ "$$attr" =~ "Updated" ]]; then \
				echo "file changed: $$f ($$attr)"; \
				make test; \
			fi; \
		done
