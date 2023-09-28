#!/bin/bash

# Path to the file containing Git hashes
file_path="/website/DOCKER/USERDATA/LiveDev/userdata-start-aimless-abbott/VERSIONS.sh"

read -p "Please input the deployment name you are moving like aimless-abbott: " deployment
# deployment=aimless-abbott

# Read the Git hashes from the file
read -r SITE_GIT_COMMIT_HASH < <(grep "SITE_GIT_COMMIT_HASH=" "$file_path" | cut -d "=" -f 2-)
read -r GEMS_GIT_COMMIT_HASH < <(grep "GEMS_GIT_COMMIT_HASH=" "$file_path" | cut -d "=" -f 2-)
read -r GMML_GIT_COMMIT_HASH < <(grep "GMML_GIT_COMMIT_HASH=" "$file_path" | cut -d "=" -f 2-)
read -r MD_UTILS_GIT_COMMIT_HASH < <(grep "MD_UTILS_GIT_COMMIT_HASH=" "$file_path" | cut -d "=" -f 2-)

declare -a repositories=(
    $SITE_GIT_COMMIT_HASH
    $GEMS_GIT_COMMIT_HASH
    $GMML_GIT_COMMIT_HASH
    $MD_UTILS_GIT_COMMIT_HASH
)

declare -a directories=(
    "/website/DOCKER/GLYCAM/$deployment"
    "/website/DOCKER/GLYCAM/$deployment/V_2/Web_Programs/gems"
    "/website/DOCKER/GLYCAM/$deployment/V_2/Web_Programs/gems/gmml"
    "/website/DOCKER/GLYCAM/$deployment/V_2/Web_Programs/gems/External/MD_Utils"
)

for ((i=0; i<${#directories[@]}; i++))
do
    directory="${directories[$i]}"
    repo="${repositories[$i]}"
    cd "$directory" || exit 1
    hash_from_file="${repositories[$i]}"
    hash_from_git=$(git rev-parse HEAD)
    hash_from_file="${hash_from_file//\"/}" 
    if [[ "$hash_from_file" == "$hash_from_git" ]]; then
        echo "Git hashes match for repository ${repo}"
    else
        echo "Git hashes do not match for repository ${repo}"
        echo "Hash from file: ${hash_from_file}"
        echo "Hash from Git: ${hash_from_git}"
    fi
    cd - >/dev/null || exit 1
done
