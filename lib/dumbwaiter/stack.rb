require "dumbwaiter/app"
require "dumbwaiter/deployment"
require "dumbwaiter/layer"

class Dumbwaiter::Stack
  attr_reader :opsworks, :opsworks_stack

  class NotFound < Exception; end

  def self.all(opsworks = Aws::OpsWorks.new(region: "us-east-1"))
    opsworks.describe_stacks.stacks.map { |stack| new(stack, opsworks) }
  end

  def self.find(stack_name, opsworks = Aws::OpsWorks.new(region: "us-east-1"))
    stack = all(opsworks).detect { |stack| stack.name == stack_name}
    raise NotFound.new("No stack found with name #{stack_name}") if stack.nil?
    stack
  end

  def initialize(opsworks_stack, opsworks = Aws::OpsWorks.new(region: "us-east-1"))
    @opsworks = opsworks
    @opsworks_stack = opsworks_stack
  end

  def name
    opsworks_stack.name
  end

  def id
    opsworks_stack.stack_id
  end

  def color
    opsworks_stack.attributes["Color"]
  end

  def apps
    @apps ||= Dumbwaiter::App.all(self, opsworks)
  end

  def deployments
    @deployments ||= Dumbwaiter::Deployment.all(self, opsworks)
  end

  def layers
    @layers ||= Dumbwaiter::Layer.all(self, opsworks)
  end

  def rechef
    opsworks.create_deployment(stack_id: id, command: {name: "update_custom_cookbooks"})
  end
end
