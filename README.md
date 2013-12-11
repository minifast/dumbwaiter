Dumbwaiter [![Build Status](https://travis-ci.org/minifast/dumbwaiter.png)](https://travis-ci.org/minifast/dumbwaiter) [![Code Climate](https://codeclimate.com/github/minifast/dumbwaiter.png)](https://codeclimate.com/github/minifast/dumbwaiter)
==========

Dumbwaiter hoists your Rails application up to OpsWorks and ratchets deployment
information back down.


Origin
------

Before Scalarium became OpsWorks, they maintained a gem that did the sorts of
functions described here.  Like Heroku Toolbelt, the Scalarium gem offered users
a very basic workflow experience: upload and run Chef recipes, execute commands
remotely and watch their output.


Goals
-----

Dumbwaiter prescribes a very specific OpsWorks-centric workflow with the same
feeling of the Scalarium gem's CLI:

  * Create OpsWorks stacks, layers and instances via YAML files
  * Collect custom Chef cookbooks via Berkshelf and upload to S3
  * Create an application corresponding to a GitHub repo
  * Run versioned deployments, rollbacks and one-off recipes


Non-Goals
---------

Dumbwaiter only deals with OpsWorks workflow, excluding:

  * Standing up VPCs
  * Running CloudFormation templates
  * One-off bash-level commands(^) and log tailing

`^ Making a cookbook to run one-off commands is totally not unheard-of.`


Installation
------------

Add this line to your application's Gemfile:

    gem 'dumbwaiter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dumbwaiter


Usage
-----

Deploy the "cinnamon" branch of the "syrup" application to the "Pancake" stack:

  `dumbwaiter deploy Pancake syrup cinnamon`

List the deployments on the "Maniacal Checklist" stack:

  `dumbwaiter list "Maniacal Checklist"`

Upload all the custom cookbooks for the "Sweden" stack:

  `dumbwaiter rechef Sweden`

Roll back the "Snowman" stack's "dandruff" application:

  `dumbwaiter rollback Snowman dandruff`

List the stacks and apps in your OpsWorks environment:

  `dumbwaiter stacks`


Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
