require "dumbwaiter/instance"

class Dumbwaiter::Layer
  attr_reader :stack, :opsworks_layer, :opsworks

  class NotFound < Exception; end

  def self.all(stack, opsworks = Aws::OpsWorks.new(region: "us-east-1"))
    opsworks.describe_layers(stack_id: stack.id).layers.map { |layer| new(stack, layer, opsworks) }
  end

  def self.find(stack, layer_name, opsworks = Aws::OpsWorks.new(region: "us-east-1"))
    layer = all(stack, opsworks).detect { |layer| layer.shortname == layer_name }
    raise NotFound.new("No layer found with name #{layer_name}") if layer.nil?
    layer
  end

  def initialize(stack, opsworks_layer, opsworks = Aws::OpsWorks.new(region: "us-east-1"))
    @stack = stack
    @opsworks_layer = opsworks_layer
    @opsworks = opsworks
  end

  def id
    opsworks_layer.layer_id
  end

  def shortname
    opsworks_layer.shortname
  end

  def run_recipe(recipe)
    opsworks.create_deployment(
      stack_id: stack.id,
      instance_ids: instances.map(&:id),
      command: {
        name: "execute_recipes",
        args: {recipes: [recipe]}
      }
    )
  end

  def instances
    @instances ||= Dumbwaiter::Instance.all(self, opsworks)
  end
end
