#!/bin/bash
 
set -e

###################################
##### function to exit script #####
###################################
function exitScript()
{
    local message=$1
    [ -z "$message" ] && message="Died"
    echo -e "${RED}[$FAILED] $message at ${BASH_SOURCE[1]}:${FUNCNAME[1]} line ${BASH_LINENO[0]}.${RESET}" >&2
    exit 1
}

##################################################
##### function to download shellcheck binary #####
##################################################
function download_shellcheck()
{
    download_url="https://github.com/koalaman/shellcheck/releases/download/${INPUT_VERSION}/shellcheck-${INPUT_VERSION}.linux.x86_64.tar.xz"
    echo $download_url
    curl -Lso "sc.tar.xz" "$download_url" || exitScript "Failed to download shellcheck, exiting..."
    tar -xf "sc.tar.xz" || exitScript "Failed to extract shellcheck, exiting..."
    mv "shellcheck-${INPUT_VERSION}/shellcheck" "${ACTION_PATH}/shellcheck" && rm -f sc.tar.xz
    echo -e "${CYAN}[$SUCCESS] shellcheck downloaded ${RESET}"
}

##################################################
##### function to combine all passed options #####
##################################################
function combine_passed_options()
{
    [ -n "${INPUT_SEVERITY}" ] && options+=("-S ${INPUT_SEVERITY}")
    options+=("--format=${INPUT_FORMAT}")
    echo "::set-output name=options::${options[@]}"
    echo -e "${CYAN}[$SUCCESS] shellcheck passed options gathered ${RESET}"
}

#################################################
##### function to gather all excluded paths #####
#################################################
function gather_excluded_paths()
{
    excludes+=("! -path \"*./.git/*\"")
    excludes+=("! -path \"*.go\"")
    excludes+=("! -path \"*/mvnw\"")
    if [[ -n "${INPUT_IGNORE}" ]]; then
       echo "::warning::ignore is deprecated. Please use ignore_paths instead"
       for path in ${INPUT_IGNORE}; do
          echo "::debug:: Adding "$path" to excludes"
          excludes+=("! -path \"*./$path/*\"")
          excludes+=("! -path \"*/$path/*\"")
       done
    else
       for path in ${INPUT_IGNORE_PATHS}; do
          echo "::debug:: Adding "$path" to excludes"
          excludes+=("! -path \"*./$path/*\"")
          excludes+=("! -path \"*/$path/*\"")
       done
    fi

    for name in ${INPUT_IGNORE_NAMES}; do
       echo "::debug:: Adding "$name" to excludes"
       excludes+=("! -name $name")
    done
    echo "::set-output name=excludes::${excludes[*]}"
    echo -e "${CYAN}[$SUCCESS] shellcheck excluded paths gathered ${RESET}"
}

##################################################
##### function to gather all base file paths #####
##################################################
function gather_file_paths()
{
    shebangregex="^#! */[^ ]*/(env *)?[abk]*sh"
    for path in $(find "${INPUT_SCANDIR}" -type f -type f $excludes '(' \
       -name '*.bash' \
       -o -name '.bashrc' \
       -o -name 'bashrc' \
       -o -name '.bash_aliases' \
       -o -name '.bash_completion' \
       -o -name '.bash_login' \
       -o -name '.bash_logout' \
       -o -name '.bash_profile' \
       -o -name 'bash_profile' \
       -o -name '*.ksh' \
       -o -name 'suid_profile' \
       -o -name '*.zsh' \
       -o -name '.zlogin' \
       -o -name 'zlogin' \
       -o -name '.zlogout' \
       -o -name 'zlogout' \
       -o -name '.zprofile' \
       -o -name 'zprofile' \
       -o -name '.zsenv' \
       -o -name 'zsenv' \
       -o -name '.zshrc' \
       -o -name 'zshrc' \
       -o -name '*.sh' \
       -o -path '*/.profile' \
       -o -path '*/profile' \
       -o -name '*.shlib' \
       ${INPUT_ADDITIONAL_FILES} \
    ')'\
     -print); do
     filepaths+=("$path");
    done

    for file in $(find "${INPUT_SCANDIR}" $excludes -type f ! -name '*.*' -perm /111  -print); do
        head -n1 "$file" | grep -Eqs "$shebangregex" || continue
        filepaths+=("$file");
    done
    echo "::set-output name=filepaths::${filepaths[*]}"
    echo -e "${CYAN}[$SUCCESS] shellcheck file paths gathered ${RESET}"
}

#############################################
##### function to run shellcheck binary #####
#############################################
function run_shellcheck()
{
    if [[ -n "${INPUT_CHECK_TOGETHER}" ]]; then
      shellcheck $options $filepaths || exitScript "ShellCheck found linting issue in one or more files, exiting..."
    else
      for file in $filepaths; do
         echo "::debug::Checking $file"
         shellcheck $options $file || exitScript "ShellCheck found linting issue in file $file, exiting..."
      done
    fi
    echo -e "${CYAN}[$SUCCESS] shellcheck executed ${RESET}"
}

RED='\033[0;31m'
RESET='\033[0m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
SUCCESS='\u2714'
FAILED='\u274c'

declare -a options filepaths excludes

download_shellcheck
combine_passed_options
gather_excluded_paths
gather_file_paths
run_shellcheck
