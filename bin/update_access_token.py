#!/usr/bin/python
import os
import ConfigParser
import sys
import errno

import boto
from boto.sts import STSConnection

import argparse
import json
import ast

def parse_args():
    """
    Parses the command line arguments
    """ 
    parser = argparse.ArgumentParser(description='updates AWS STS tokens')
    parser.add_argument(
        "-p", "--profile",
        required=False,
        help='the AWS profile to use')
    parser.add_argument(
        "-o", "--outprofile",
        required=False,
        default="default",
        help='the AWS profile to write credentials to')
    parser.add_argument(
        "-c", "--code",
        required=False,
        help='the MFA code')
    parser.add_argument(
        "-t", "--token",
        required=False,
        type=argparse.FileType('r'),
        help='a read from a file a temporary token payload to process and save')
    return parser.parse_args()

args = parse_args()

# Constants
AWS_ACCESS_KEY_ID = "aws_access_key_id"
AWS_SECRET_ACCESS_KEY = "aws_secret_access_key"
AWS_SESSION_TOKEN = "aws_session_token"
AWS_MFA_DEVICE = "aws_mfa_device"
DEFAULT_PROFILE = "testmarketingcloud"

# Set the path to the config file to update
config_file_path = os.path.expanduser("~/.aws/credentials")

# Ensure that the ~/.aws exists
try:
    os.makedirs(os.path.expanduser("~/.aws"))
except OSError as e:
    if e.errno != errno.EEXIST:
        raise

# Update the static profile with the static credentials
config = ConfigParser.ConfigParser()
config.read(config_file_path)

# Write out to default
outprofile = args.outprofile

print("writing out credentials using profile: {}".format(outprofile))
config.remove_section(outprofile)
ConfigParser.DEFAULTSECT = outprofile

# if a code or token was specified, skip the question and use the profile argument
if args.token is not None: 
    fileData = json.load(args.token)
    tempCredentials = fileData['Credentials']
    print("reading token from {}".format(args.token))
    config.set(ConfigParser.DEFAULTSECT, AWS_ACCESS_KEY_ID, tempCredentials['AccessKeyId'])
    config.set(ConfigParser.DEFAULTSECT, AWS_SECRET_ACCESS_KEY, tempCredentials['SecretAccessKey'])
    config.set(ConfigParser.DEFAULTSECT, AWS_SESSION_TOKEN, tempCredentials['SessionToken'])

else:

    # when a code is specified use the default profile by default and don't prompt
    profile = args.profile
    if args.code is not None: 
        if profile is None: 
            profile = DEFAULT_PROFILE
        print("using profile {} mfa code: {}".format(args.profile, args.code))
    # if nothing is changed 
    elif profile is None:
        # Get the name of the static profile
        profile = raw_input("Enter the AWS Credentials Profile [enter for {}]: ".format(DEFAULT_PROFILE))
        if len(profile) == 0:
            profile = DEFAULT_PROFILE

    # Make sure we have a section for the desired profile
    if config.has_section(profile) == False:
        config.add_section(profile)

    # Make sure we have the access key id and secret in the profile section
    write_config = False

    if config.has_option(profile, AWS_ACCESS_KEY_ID) == False:
        access_key_id = raw_input("Enter your AWS Access Key ID: ")
        config.set(profile, AWS_ACCESS_KEY_ID, access_key_id)
        write_config = True

    if config.has_option(profile, AWS_SECRET_ACCESS_KEY) == False:
        secret_access_key = raw_input("Enter your AWS Secret Access Key: ")
        config.set(profile, AWS_SECRET_ACCESS_KEY, secret_access_key)
        write_config = True

    if config.has_option(profile, AWS_MFA_DEVICE) == False:
        mfa_device = raw_input("Enter your username: ")
        config.set(profile, AWS_MFA_DEVICE, mfa_device)
        write_config = True

    if write_config == True:
        with open(config_file_path, 'w') as config_file:
            config.write(config_file)


    # Open the connection, specifying the profile to use
    sts_connection = STSConnection(profile_name=profile)

    # Prompt for MFA device and time-based one-time password (TOTP)
    mfa_device = config.get(profile, AWS_MFA_DEVICE)
    serial_number = "arn:aws:iam::973692506099:mfa/" + mfa_device

    # use the passed in code if any
    mfa_TOTP = args.code
    if args.code is None:
        mfa_TOTP = raw_input("Enter your MFA code: ")

    # Get temp credentials
    tempCredentials = sts_connection.get_session_token(
        duration=28800,
        mfa_serial_number=serial_number,
        mfa_token=mfa_TOTP
    )
    config.set(ConfigParser.DEFAULTSECT, AWS_ACCESS_KEY_ID, tempCredentials.access_key)
    config.set(ConfigParser.DEFAULTSECT, AWS_SECRET_ACCESS_KEY, tempCredentials.secret_key)
    config.set(ConfigParser.DEFAULTSECT, AWS_SESSION_TOKEN, tempCredentials.session_token)

# Write out the config
with open(config_file_path, 'w') as configfile:
    config.write(configfile)

print("\nAll set! You can now use AWS CLI commands.")