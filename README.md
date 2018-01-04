# assume-aws-role-mfa

shell script to assume a role in AWS when you also have multi-factor authentication

## Overview

Assume the given role, by updating the ./aws/config file for default and $PROFILE profiles with temporary credentials.

This allows terraform (or any other application requiring AWS access via role) to run for an hour.

Then you have to run the assume_role script again.


## Usage
```
     $./assume_role.sh 999999

 where 999999 is your One Time MFA Code
```
## Setup

* Global Change nturner to your user name

* Create a ./aws/credentials that contains
```
 [nturner]
 aws_access_key_id = XXXXXXXXXXXXXXXXXXX
 aws_secret_access_key = YYYYYYYYYYYYYYYYYYYYYYYY

 where nturner is your username
```
* Update PROFILE parameter to the profile in addition to default to create in the ./aws/credentials file.

* Update ROLEARN parameter to the Role that you wish ro assume.

## Requirement

aws cli must be installed.

## Issues

We update both the default and internal (or what is specified in $PROFILE) because terraform when doing

terraform init uses the default profile but on terraform plan and terraform apply use the aws config specified inside the aws provider definition.

This is because at terraform init time terraform does not have access to the aws provider definition.


## To Do

Currently works for internal need to consider production use.

# Other Scripts

More generalised script: 

https://github.com/ThoughtWorksInc/aws_role_credentials

and a good explaination: 

http://peter.gillardmoss.me.uk/blog/2015/11/13/safety-first-with-aws-roles-and-sts/

