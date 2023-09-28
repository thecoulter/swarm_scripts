#!/bin/bash

source /home/webdev/.bashrc

read -p "Please input the deployment name you are moving like aimless-abbott: " deployment
# deployment=complaining-colborn
# deplyment=$1

# do not alter this list or the order of it
declare -a repos=(
    "web"
    "gems"
    "gmml"
    "md"
)

# do not alter this list or the order of it
declare -a directories=(
    "/website/DOCKER/GLYCAM/$deployment"
    "/website/DOCKER/GLYCAM/$deployment/V_2/Web_Programs/gems"
    "/website/DOCKER/GLYCAM/$deployment/V_2/Web_Programs/gems/gmml"
    "/website/DOCKER/GLYCAM/$deployment/V_2/Web_Programs/gems/External/MD_Utils"
)

# Move pre-push hook to pre-push.inactive in each directory
for dir in "${directories[@]}"; do
    cd "$dir" && mv .git/hooks/pre-push .git/hooks/pre-push.inactive
    echo "Moved .git/hooks/pre-push to .git/hooks/pre-push.inactive in $dir"
done

read -p "Are you moving to dev or actual: " movingto
# movingto=dev
# movingto=$2

# Check if it's a dry run or not
# read -p "Is this a dry run? (yes/no): " dry_run
dry_run=no

for ((i=0; i<${#directories[@]}; i++))
do
    directory="${directories[$i]}"
    repo="${repos[$i]}"
#    echo $repo
    cd "$directory" || exit 1
    
    branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p' | grep -o "test")
    if [ "$branch" = "test" ]; then
	if [ "$movingto" = "dev" ]; then
           new_branch="$repo-$movingto"
        else
           new_branch="$movingto"
        fi
        git tag -a $deployment -m "Script setting deployment tag"
        git push origin $deployment
        git remote set-branches --add origin ${movingto}
        git fetch origin
        git checkout $new_branch
        git rebase $deployment
        git push $new_branch
	echo $new_branch
    else
        echo "Git branch is not on test. Please change branch to test."
    fi
    cd - >/dev/null || exit 1
done
