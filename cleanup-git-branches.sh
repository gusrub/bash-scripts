#!/bin/bash

# Branches we don't want to remove
keep_branches=("develop" "staging")
branches_to_remove=()

printf "\n================================================================================"
printf "\nTHE FOLLOWING BRANCHES HAVE BEEN ALREADY MERGED AND WILL BE REMOVED!:"
printf "\n================================================================================"
printf "\n"

while IFS= read -r branch
do
	trimmed=`echo $branch | xargs`

	exist=0
	for keep in "${keep_branches[@]}"; do
		if [[ $keep == $trimmed ]]; then
			exist=1
			break
		fi
	done

	if [[ $exist -ne 1 ]]; then
		echo "$trimmed"
    	branches_to_remove+=("$trimmed")
	fi
done < <(git branch --merged | grep -v "\*")

printf "\nAre you sure you want to remove the above branches (both locally and remote)? Y/N? (then press [ENTER]): "

function do_removal {
	while read response; do
		case $response in
			"Y") break ;;
			"N") safe_exit ;;
			*) printf "Incorrect answer. Please select either Y(es) or N(o): "	;;
		esac
	done

	for branch in "${branches_to_remove[@]}"; do
		printf "\nDeleting branch '$branch' \n"

		git push --delete origin $branch
		git branch -d $branch
		git remote prune origin

		if [[ $? -ne 0 ]]; then
			printf "\nThere was a problem removing the '$branch' branch"
			exit 1
		fi
	done

	exit 0
}

function safe_exit {
	printf "Doing nothing and safely exiting.\n"
	exit 0
}

do_removal


