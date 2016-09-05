.DEFAULT: test docs

SHELL=/bin/bash

test:
	bats -p tests

docs:
	bash -c '\
		. ./git-fiddle;\
		awk -v help_text="\\$$ git fiddle -h\n$$(derive_help ./git-fiddle)" "\
			BEGIN              { x = 0 };\
			/\`\`\`usage/      { x = 1; print; next };\
			x == 0             { print; }\
			/\`\`\`/ && x == 1 { x = 0; print help_text; print };\
		" < README.md > README.md.tmp;\
		mv README.md{.tmp,};\
	'

watch:
	fswatch -x git-fiddle _fiddle_seq_editor tests/*.bats tests/*.bash 2>/dev/null | \
		while read -r f attr; do \
			if ! [ -z "$$f" ] && [[ "$$attr" =~ "Updated" ]]; then \
				echo "file changed: $$f ($$attr)"; \
				make test; \
			fi; \
		done
