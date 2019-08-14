#!/usr/bin/env bash

# Function to clear current MFA configuration
function unset_mfa() {
  unset AWS_ACCESS_KEY_ID;
  unset AWS_SECRET_ACCESS_KEY;
  unset AWS_SESSION_TOKEN;
  unset AWS_MFA_EXPIRY;
}
export -f unset_mfa;

# Explicitly set AWS Credentials based on MFA configuration
# associate with the current AWS_PROFILE.
#
# Does not support the use of STS against credentials manually
# entered into environment variables. Creds should be elsewhere
# on the boto search path.
function sts() {

  # Remove any environment variables previously set by sts()
  unset_mfa

  # Get MFA Serial
  #
  # Assumes "iam list-mfa-devices" is permitted without MFA
  mfa_serial="$(aws iam list-mfa-devices --query 'MFADevices[*].SerialNumber' --output text)";
  if ! [ "${?}" -eq 0 ]; then
    echo "Failed to retrieve MFA serial number" >&2;
    return 1;
  fi;

  # Read the token from the console
  echo -n "MFA Token Code: ";
  read token_code;

  # Call STS to get the session credentials
  #
  # Assumes "sts get-session-token" is permitted without MFA
  echo "aws sts get-session-token --token-code "${token_code}" --serial-number "${mfa_serial}" --output text"
  session_token=($(aws sts get-session-token --token-code "${token_code}" --serial-number "${mfa_serial}" --output text));
  if ! [ "${?}" -eq 0 ]; then
    echo "STS MFA Request Failed" >&2;
    return 1;
  fi;

  # Set the environment credentials specifically for this command
  # and execute the command
  export AWS_ACCESS_KEY_ID="${session_token[1]}";
  export AWS_SECRET_ACCESS_KEY="${session_token[3]}";
  export AWS_SESSION_TOKEN="${session_token[4]}";
  export AWS_MFA_EXPIRY="${session_token[2]}";

  if [[ -n "${AWS_ACCESS_KEY_ID}" && -n "${AWS_SECRET_ACCESS_KEY}" && -n "${AWS_SESSION_TOKEN}" ]]; then
    echo "MFA Succeeded. With great power comes great responsibility...";
    return 0;
  else
    echo "MFA Failed" >&2;
    return 1;
  fi;
}
export -f sts;

function aws_clock_print() {
  output="[AWS_PROFILE: ";
  [ -n "${AWS_PROFILE}" ] && output+="${AWS_PROFILE}" || output+="default";
  if [ -n "${AWS_MFA_EXPIRY}" ]; then
    expire_seconds="$(expr '(' $(date -j -f "%Y-%m-%dT%H:%M:%SZ" "${AWS_MFA_EXPIRY}" +%s) - $(date +%s) ')' )";
    if [ "${expire_seconds}" -gt 0 ]; then
      output+=", MFA TTL: $(date -r "${expire_seconds}" +"%Hh %Mm %Ss")";
    else
      output+=", MFA EXPIRED!";
    fi;
  fi;

  output+="]";
  tput_x=$(( $(tput cols)-${#output} ));
  tput sc;
  tput cup 1 "${tput_x}";
  tput bold;
  echo -n "${output}";
  tput rc;
}
export -f aws_clock_print

export PROMPT_COMMAND="aws_clock_print; ${PROMPT_COMMAND}";
