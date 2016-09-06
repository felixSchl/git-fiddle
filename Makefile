.DEFAULT: test docs

SHELL=/bin/bash

test:
	bats -p tests

docs:
	source ./git-fiddle;\
	awk '\
		BEGIN                        { x = 0; f = 0; };\
		FNR == 1                     { f++; };\
		f == 1 && help_text == ""    { help_text = $$0; next };\
		f == 1                       { help_text = help_text "\n" $$0; next };\
		f == 2 && /\`\`\`usage/      { x = 1; print; next };\
		f == 2 && x == 0             { print; next; };\
		f == 2 && /\`\`\`/ && x == 1 { x = 0; print help_text; print };\
	' <(\
		echo "\$$ git fiddle -h";\
		echo "$$(derive_help ./git-fiddle)";\
		) README.md > README.md.tmp;\
	mv README.md{.tmp,};\

watch:
	fswatch -x git-fiddle _fiddle_seq_editor tests/*.bats tests/*.bash 2>/dev/null | \
		while read -r f attr; do \
			if ! [ -z "$$f" ] && [[ "$$attr" =~ "Updated" ]]; then \
				echo "file changed: $$f ($$attr)"; \
				make test; \
			fi; \
		done
