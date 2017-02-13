# Cupper

[![Join the chat at https://gitter.im/cupper-reverse-recipe/cupper](https://badges.gitter.im/cupper-reverse-recipe/cupper.svg)](https://gitter.im/cupper-reverse-recipe/cupper?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Coverage Status](https://coveralls.io/repos/github/cupper-reverse-recipe/cupper/badge.svg?branch=master)](https://coveralls.io/github/cupper-reverse-recipe/cupper?branch=master)
[![Build Status](https://travis-ci.org/cupper-reverse-recipe/cupper.svg?branch=master)](https://travis-ci.org/cupper-reverse-recipe/cupper)

Taste your environment and creates a cookbook for it!
Cupper is a command line tool that runs in some environment (see supoorted
platforms below) and creates a cookbook based on it. It will collect
information about the package installed, file configuration, groups, users,
links, links and services. Once you have this cookbook, you can change
according to your needs, or just runs it in another environment.

## Support Platform

Currently, Cupper support the platforms listed below. It means that we
tested on this specific platforms and versions, but may work on others
version. Let us know :)

| Debian       | Arch            |
| :----------: | :-------------: |
| Jessie 8.6   | (Coming soon)   |
| Jessie 8.2   |        .        |


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cupper'
```

And then execute:

    $ bundle

Or install it yourself with:

    $ gem install cupper

## Usage

Cupper is a command line tool. All commands are available through bash/shell
terminal.
First create a Cupper project with the following command:

```
$ cupper create <project_name>
```

This will create a directory within a given name. The structure of the
Cupper project contains:

```
.project
  |
  |- cookbooks/
  |- Cupperfile
  |- .sensibles
```
- **cookbook**: the recipe that are generated is stored in this directory
- **Cupperfile**: configuration file that allows you to customize some items
inside the cookbook
- **.sensibles**: specifies all files that are not suppose to be collected
(patten witha a regex is given)

Inside the project directory you can run the command:
```
$ cupper generate
```
This will generate a cookbook based on the configurations on the machine
and store in `cookbooks/` directory.


## Development

This is a common gem, so doesn't needs a bunch of configuration on your
environment to develop something. Just use a ruby environment with rbenv
or RVM (ruby 2.2.0 or higher).

### Ohai

We use [Ohai](https://github.com/chef/ohai) gem to extract the information
about the environment. We created our Ohai plugins, it's code made in ruby,
so nothing unusual. Check the official
[doc](https://docs.chef.io/ohai.html) of Ohai for more knowledge about it.

## Contributing

Any contribution are welcome :)
Steps:
- Make a fork
- Clone the repository
- Bundle!
- Make a change
- Send a Pull Request

## Found any bug? Open a issue

Just go to the
[issue](https://github.com/cupper-reverse-recipe/cupper/issues) page and
report the problem. Use a lablel to make it easier to identify if it's
a bug or a suggestion.
