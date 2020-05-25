Originally from [forked docker-machine inventory plugin](https://github.com/benroose/ansible-docker-machine-inventory-plugin)

# Docker Machine dynamic inventory plugin for Ansible

A [dynamic inventory plugin](https://docs.ansible.com/ansible/latest/plugins/inventory.html) for Ansible. Tested with Ansible 2.7.10 and Python 3.6.7 on Ubuntu Linux 18.04 LTS with Digital Ocean Droplets created by Docker Machine.

## Inspiration

This plugin is based on and is very similar to the Ansible 2.8 [docker_swarm](https://docs.ansible.com/ansible/devel/plugins/inventory/docker_swarm.html?highlight=docker_swarm) and [aws_ec2](https://docs.ansible.com/ansible/devel/plugins/inventory/aws_ec2.html?highlight=aws_ec2) Dynamic Inventory plugins.

While there are other similar solutions out there, I did not find an existing Docker Machine dynamic inventory _plugin_, only _scripts_ (e.g. [this](https://gist.github.com/nathanleclaire/1bbf18de7c73f89aa36c)).

## Status

This plugin was created for and is being used by the [NLnet Labs Gantry project](https://github.com/NLnetLabs/gantry).

This plugin has been submitted for inclusion in Ansible core. See [PR #54946](https://github.com/ansible/ansible/pull/54946).

## Features

This plugin teaches Ansible about which Docker Machine machines exist and how to connect to them via SSH so that the Ansible controller can execute commands on the remote machine.

It also makes available the DOCKER_xxx environment variables output by `docker-machine env <machine-name>` as Ansible host variables, prefixed with `dm_`. These are intended to be used to set Ansible or environment variables such that Docker commands (e.g. docker ps, docker-compose up) will be executed against the Docker daemon running on the remote machine and not the local Docker daemon.

Like the Docker Swarm and AWS EC2 plugins it supports `keyed_groups` and other `constructable` ways of dynamically defining Ansible host groups.

If `verbose_output` is enabled it also exposes the entire Docker Machine ```inspect``` output as an ansible inventory host variable called `docker_machine_node_attributes` (matching the naming style used by the Docker Swarm inventory plugin).

## Requirements

Docker Machine must be [installed](https://docs.docker.com/machine/install-machine/) on the Ansible controller.

## Usage

1. Tell Ansible where to find the plugin. See the [Ansible documentation](https://docs.ansible.com/ansible/latest/dev_guide/developing_locally.html#adding-a-plugin-locally) for all the possible ways that you can do this.
2. Tell Ansible how to configure the plugin by pointing it to a `docker_machine.yml` configuration file that you create.

E.g.

```
$ export ANSIBLE_INVENTORY_ENABLED=docker_machine
$ export ANSIBLE_INVENTORY_PLUGINS=/tmp/ansible-docker-machine-inventory-plugin
$ git clone https://github.com/ximon18/ansible-docker-machine-inventory-plugin.git ${ANSIBLE_INVENTORY_PLUGINS}
$ vi ${ANSIBLE_INVENTORY_PLUGINS}/docker_machine.yml
$ ansible -i ${ANSIBLE_INVENTORY_PLUGINS}/docker_machine.yml -m ping all
```

To find out what the plugin has discovered do:

```
$ ansible-inventory -i ${ANSIBLE_INVENTORY_PLUGINS}/docker_machine.yml --graph --vars
```

## Documentation

To read the full plugin docs you can use the `ansible-doc` command:

```
$ ansible-doc -t inventory docker_machine
```

E.g. at the time of writing on my local Ansible 2.7.10 installation this produces:

```
> INVENTORY    (/root/.ansible/plugins/inventory/docker_machine.py)

        Get inventory hosts from Docker Machine. Uses a YAML configuration file that ends with docker_machine.(yml|yaml). The plugin sets standard host variables
        `ansible_host', `ansible_port', `ansible_user' and `ansible_ssh_private_key'. The plugin stores the Docker Machine 'env' output variables in `dm_' prefixed host
        variables.

OPTIONS (= is mandatory):

- cache
        Toggle to enable/disable the caching of the inventory's source data, requires a cache plugin setup to work.
        [Default: False]
        set_via:
          env:
          - name: ANSIBLE_INVENTORY_CACHE
          ini:
          - key: cache
            section: inventory

        type: boolean

- cache_connection
        Cache connection data or path, read cache plugin documentation for specifics.
        [Default: (null)]
        set_via:
          env:
          - name: ANSIBLE_INVENTORY_CACHE_CONNECTION
          ini:
          - key: cache_connection
            section: inventory


- cache_plugin
        Cache plugin to use for the inventory's source data.
        [Default: (null)]
        set_via:
          env:
          - name: ANSIBLE_INVENTORY_CACHE_PLUGIN
          ini:
          - key: cache_plugin
            section: inventory


- cache_timeout
        Cache duration in seconds
        [Default: 3600]
        set_via:
          env:
          - name: ANSIBLE_INVENTORY_CACHE_TIMEOUT
          ini:
          - key: cache_timeout
            section: inventory

        type: integer

- compose
        create vars from jinja2 expressions
        [Default: {}]
        type: dictionary

- daemon_required
        when true, hosts for which Docker Machine cannot output Docker daemon connection environment variables will be skipped.
        [Default: True]
        type: bool

- groups
        add hosts to group based on Jinja2 conditionals
        [Default: {}]
        type: dictionary

- keyed_groups
        add hosts to group based on the values of a variable
        [Default: []]
        type: list

= plugin
        token that ensures this is a source file for the `docker_machine' plugin.
        (Choices: docker_machine)

- running_required
        when true, hosts which Docker Machine indicates are in a state other than `running' will be skipped.
        [Default: True]
        type: bool

- strict
        If true make invalid entries a fatal error, otherwise skip and continue
        Since it is possible to use facts in the expressions they might not always be available and we ignore those errors by default.
        [Default: False]
        type: boolean

- verbose_output
        when true, include all available nodes metadata (e.g. Image, Region, Size) as a JSON object.
        [Default: True]
        type: bool


REQUIREMENTS:  L(Docker Machine,https://docs.docker.com/machine/)

AUTHOR: Ximon Eighteen (@ximon18)
NAME: docker_machine
PLUGIN_TYPE: inventory

EXAMPLES:

# Minimal example
plugin: docker_machine

# Example using constructed features to create a group per Docker Machine driver
# (https://docs.docker.com/machine/drivers/), e.g.:
#   $ docker-machine create --driver digitalocean ... mymachine
#   $ ansible-inventory -i ./path/to/docker-machine.yml --host=mymachine
#   {
#     ...
#     "digitalocean": {
#       "hosts": [
#           "mymachine"
#       ]
#     ...
#   }
strict: no
keyed_groups:
  - separator: ''
    key: docker_machine_node_attributes.DriverName

# Example grouping hosts by Digital Machine tag
strict: no
keyed_groups:
  - prefix: tag
    key: 'dm_tags'

# Example using compose to override the default SSH behaviour of asking the user to accept the remote host key
compose:
  ansible_ssh_common_args: '"-o StrictHostKeyChecking=accept-new"'
```

END
