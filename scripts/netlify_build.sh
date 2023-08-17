#!/bin/bash

set -e
set -o pipefail

export PATH="${HOME}"/.local/bin:"${PATH}"

if [ "$NETLIFY" != "true" ]; then
	echo "Installing pre-commit and hooks"
	pip install --user pipx
	pipx install --force pre-commit
	pre-commit install --install-hooks
	pre-commit run --all-files
fi

bash ./tests/scripts/hugo-audit.sh
bash ./tests/scripts/check-internal-links.sh

rm -rf public

export HUGO_PARAMS_DEFAULTCANONICAL="$URL"

if [ "$CONTEXT" = "production" ]; then
	export HUGO_PARAMS_DEPLOYEDBASEURL="$URL"
	export BASEURL="$URL"
else
	export HUGO_PARAMS_DEPLOYEDBASEURL="$DEPLOY_PRIME_URL"
	export BASEURL="$DEPLOY_PRIME_URL"
fi

HUGO_RESOURCEDIR="$(pwd)/resources" hugo --gc --minify -b $BASEURL
