Dumbwaiter [![Build Status](https://travis-ci.org/minifast/dumbwaiter.png)](https://travis-ci.org/minifast/dumbwaiter) [![Code Climate](https://codeclimate.com/github/minifast/dumbwaiter.png)](https://codeclimate.com/github/minifast/dumbwaiter)
==========

Dumbwaiter hoists your Rails application up to OpsWorks and ratchets deployment
information back down.


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

Roll back the "Snowman" stack's "dandruff" application:

  `dumbwaiter rollback Snowman dandruff`

List the deployments on the "Maniacal Checklist" stack:

  `dumbwaiter list "Maniacal Checklist"`

List the stacks and apps in your OpsWorks environment:

  `dumbwaiter stacks`


Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
