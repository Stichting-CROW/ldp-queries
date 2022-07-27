#! /bin/bash

# save LDP_USER, LDP_PASSWORD, LDP_ENDPOINT to .env
source .env

CMD_HELP='Usage: ./query-endpoint-with-saved-query.sh (FILE ...)\n\nOptional arguments:\n\tFILE:\tOne or more query files. If none supplied, git status is tested for uncommited changes in src/ dir.'
BLUE='\e[1;34m'
NC='\e[0m' # No Color

files=$@

# if empty, check for git changed files
if [[ -z $files ]]; then
	echo -e "${BLUE}# No file argument, checking for git changes in src/... ${NC}"
	if output=$(git status --porcelain src/) && [ -z "$output" ]; then
		echo -e $CMD_HELP
		exit -1
	fi
	# git status for queries in src/, then only print filenames
	files=$(git status --porcelain=2 src/ | cut -d" " -f9-)
fi

echo $files | while read -r queryfile; do
	echo -e "${BLUE}# $queryfile${NC}"
	curl -X POST -L \
		-H "Content-Type: application/sparql-query" \
		-H "Accept: text/csv" \
		--data-binary "@$queryfile" \
		-u ${LDP_USER}:${LDP_PASSWORD} \
		${LDP_ENDPOINT} | column -nts, | less
done
