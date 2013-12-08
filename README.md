Dumbwaiter
==========

Dumbwaiter hoists your Rails application up to AWS using CloudFormation templates, OpsWorks and a rope.


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

Build your CloudFormation template in `config/cloudformation.yml`.  Here's an example of a template:

    instance:
      name:


Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
