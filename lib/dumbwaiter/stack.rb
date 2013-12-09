require "dumbwaiter/app"
require "dumbwaiter/deployment"

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

  def apps
    @apps ||= Dumbwaiter::App.all(id, opsworks)
  end

  def deployments
    @deployments ||= Dumbwaiter::Deployment.all(id, opsworks)
  end
end
