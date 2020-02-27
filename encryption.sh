#!/usr/bin/env bash

# creates a keyfile with a default keysize of 512 digits
create_keyfile() {
    declare -n options_ref="$1"
    openssl rand -base64 "${options_ref[keysize]:-512}" -out "${options_ref[key_file]}"
    unset -n options_ref
}

# decrypts the 'secrets_file' with the ''key_file' and returns its content
decrypt_file() {
    declare -n options_ref="$1"

    local content=$(openssl enc -d -aes-256-cbc -iter "${options_ref[iter]:-100000}" -base64 -salt -kfile "${options_ref[key_file]}" -in "${options_ref[secrets_file]}")
    echo "$content"
    unset -n options_ref
}

encrypt_file() {
    declare -n options_ref="$1"
    log_debug "${options_ref[@]}"

    openssl enc -d -aes-256-cbc \
        -iter "${options_ref[iter]}" -base64 -salt \
        -kfile "${options_ref[key_file]}" \
        -in "${options_ref[input_file]}" \
        -out "${options_ref[secrets_file]}"
    unset -n options_ref
}

# usage:
#   declare -A crypt_options
#   crypt_options[secrets_file]="/.secrets"
#   crypt_options[key_file]="/.keyfile"
#   crypt_options[source_name]='DATABASE_PASSWORD'
#   export_encrypted_variable crypt_options
#
# keys:
#   secrets_file: path of secrets file
#   key_file: path of keyfile
#   source_name: name of the key to extract from the secrets file
#   target_name (optional): name of the variable to export the value of source_name into
#   iter (optional): openssl -iter value to use; defaults to 100000
export_encrypted_variable() {
    # you could use the options array directly, cause it's declared in the same scope
    # but's more strict to pass a name and a reference/alias
    # use bashs namevars/alias feature: https://stackoverflow.com/questions/39297530/bash-use-variable-as-name-of-associative-array-when-calling-value
    local options_array_name="$1"
    declare -n options_ref="$options_array_name"

    if [ -z "${options_ref[source_name]}" ]; then
        log_err "error: secret key name undefined or empty"
        exit 1
    fi

    local content=$(decrypt_file $options_array_name)
    # use grep with regex to find exact key without any leading or trailing chars
    local value=$(echo "${content:-}" |
        grep "^"${options_ref[source_name]}"=" |
        head -n1 |
        cut -d'=' -f2)

    # log_debug "Content: $content"
    # log_debug "Value: $value"

    if [ -z "${value}" ]; then
        log_err "error: secret key ${options_ref[source_name]} not found in ${options_ref[secrets_file]} or value is empty"
        exit 2
    fi

    if [ -z "${options_ref[target_name]}" ]; then
        options_ref[target_name]="${options_ref[source_name]}"
    fi
    # log_debug "${options_ref[source_name]}" "${options_ref[target_name]}"

    export "${options_ref[target_name]}"="$value"
    unset -n options_ref
}
