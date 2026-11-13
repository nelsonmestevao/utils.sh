#==============================================================================
NO_COLOR=\x1b[0m
OK_COLOR=\x1b[32m
ERROR_COLOR=\x1b[31m
WARN_COLOR=\x1b[33m
OK_STRING=$(OK_COLOR)✓$(NO_COLOR)
ERROR_STRING=$(ERROR_COLOR)⨯$(NO_COLOR)
WARN_STRING=$(WARN_COLOR)!$(NO_COLOR)
#------------------------------------------------------------------------------
BATS := bats -r tests
#==============================================================================

.PHONY: setup # Install package dependencies for development
setup:
	@bin/setup

.PHONY: fmt format # Run code formatters
fmt format:
	@shfmt -w -i 2 -l -ci .

.PHONY: lint # Lint the source code
lint:
	@shellcheck -xa scripts/*.sh *.sh bin/setup

.PHONY: test # Run the test suite
test:
	@$(BATS)

.PHONY: coverage # Run the test suite with coverage report
coverage:
	@kcov --clean --bash-parser="$$(command -v bash)" --include-path=scripts \
		--bash-parse-files-in-dir=scripts coverage $(BATS)

.PHONY: help # Generate list of targets with descriptions
help:
	@grep '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/\t\1\t\2/'
