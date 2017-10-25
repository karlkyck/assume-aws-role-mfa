#!/bin/bash
#
# Assume the given role, by updating the ~/aws/config file for default and <PROFILE NAME> profiles with temporary credentials.
# This allows terraform (or any other application requiring AWS access via role) to run for an hour.
# Then you have to run the assume_role script again.
# for terraform we update both the default profile and the <PROFILE NAME> profile as terraform initially uses the default profile on
# the terraform init command.
#
# Usage:
# ******
#      $./assume_role.sh 999999
#
# where 999999 is your One Time MFA Code
#
# Setup:
# ******
# 1. Update values in the script:
#     <PROFILE NAME>      to name of profile in ./aws/credentials that will be generated
#     <ROLE ACCOUNT NO>   the AWS account number of the role to assume
#     <ROLE NAME>         the name of the role to assume
#     <USER ACCOUNT NO>   the AWS account no of the user
#     <USER NAME>         the name of the user
#
# 2. Create a ./aws/credentials that contains
# [<USER NAME>]
# aws_access_key_id = XXXXXXXXXXXXXXXXXXX
# aws_secret_access_key = YYYYYYYYYYYYYYYYYYYYYYYY
#
# where <USER NAME> is your username as above
#
#
# Requirements:
# ************
# aws cli must be installed.
#
set -e

PROFILE=<PROFILE NAME>
ROLEARN="arn:aws:iam::<ROLE ACCOUNT NO>:role/<ROLE NAME>"
IAMUSER="arn:aws:iam::<USER ACCOUNT NO>:user/<USER NAME>"
MFAARN="arn:aws:iam::<USER ACCOUNT NO>:mfa/<USER NAME>"
NAME=<USER NAME>
MFACODE=$1

# KST=access*K*ey, *S*ecretkey, session*T*oken
KST=(`aws sts assume-role --role-arn "$ROLEARN" \
                          --region eu-west-1 \
                          --profile "$NAME" \
                          --role-session-name "$NAME" \
                          --serial-number "$MFAARN" \
                          --token-code $MFACODE  \
                          --query "[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]" \
                          --output text`)

aws_access_key_id="${KST[0]}"
aws_secret_access_key="${KST[1]}"
aws_session_token="${KST[2]}"

`aws configure set profile.default.region eu-west-1`
`aws configure set profile.default.aws_access_key_id $aws_access_key_id`
`aws configure set profile.default.aws_secret_access_key $aws_secret_access_key`
`aws configure set profile.default.aws_session_token $aws_session_token`

`aws configure set profile.$PROFILE.region eu-west-1`
`aws configure set profile.$PROFILE.aws_access_key_id $aws_access_key_id`
`aws configure set profile.$PROFILE.aws_secret_access_key $aws_secret_access_key`
`aws configure set profile.$PROFILE.aws_session_token $aws_session_token`


echo "ACCESS KEY $aws_access_key_id"
echo "SECRET KEY $aws_secret_access_key"
echo "SESSION TOKEN $aws_session_token"
echo ""
echo "default and $PROFILE profile updated with MFA-protected temporary credentials"

