# Gameservers on demand

This is a toolkit for creating gameservers on AWS.

The idea is to use cloudformation to spawn a Spot instance and then use scripts for provisioning while persisting data in EFS.

This way you can only run the server when you want to play, and only pay spot instance pricing for that duration.

## Notice

This toolkit is under very active development, nothing is guaranteed to work.

Currently pretty hard coded to eu-west-1 region.

Also pretty hard coded to eu-west-1a AZ.


### Prerequisites

This does not have a lot of external dependencies, but you will need the following things.

- An AWS account
    - A VPC
    - At least one subnet
    - An EFS share
    - A Security Group that allows access to it's members (use this for the EFS share)
    - A keypair
    - AMI Subscription for: ami-b5a893d3 (Ubuntu 16.04 Ireland)
    - Check the `settings` file and fill out the fields accordingly
- jq
- awscli `pip install -r requirements.txt`

### Structure

The toolkit contains a directory structure, this chapter tries to explain it.

- bin/
    - internal scripts used by the toolkit
- up.sh & down.sh
    - The two files that you will interact with
- base/
    - This is the root for the server descriptions
    - Each subdirectory is a level that depends on the parent level
        - Each level can define lifecycle scripts
            - create.sh
            - start.sh
            - stop.sh
            - destroy.sh
- settings
    - This file contains variables for configuration
- base/\*\*/settings
    - These are level specific settings, some may need manual configuration.


### Usage

Make sure your AWS credentials are setup (http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) and all "settings" files configured according to your needs.

The toolkit aims to require minimal interaction by users. After you have configured the settings files it should be one command to bring the service up.

    ./up.sh base/path/to/service/spec


Same goes for bringing a service down

    ./down.sh base/path/to/service/spec


### Power usage

Want to create your own specs? Sounds good! Here are some notes to keep in mind:

- template.yaml
    - This file is used to describe the AWS cloudformation stack
        - At this time, the stack should only create one instance under a autoscaling group.
        - The base/template.yaml is a good start, use that if you want to be safe
            - Though you might want to edit the security group at the bottom ;)
    - This file is loaded from the most specific level that has one
        - Example
            - `./up.sh base/minecraft/myconfig`
            - The scripts will first look for /base/minecraft/myconfig/template.yaml
            - If if does not exist it will continue to /base/minecraft/template.yaml
            - etc.
- settings
    - These files are loaded from bottom up
        - base/settings is loaded before base/minecraft/settings
        - This means that a subdirectory can override its parents settings
    - When these files are loaded on the server (server-boot.sh) they are also exported to be available on all levels without explicit loading.

