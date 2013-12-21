class Dumbwaiter::Instance
  attr_reader :layer, :opsworks_instance, :opsworks

  def self.all(layer, opsworks = Aws::OpsWorks.new(region: "us-east-1"))
    instances = opsworks.describe_instances(layer_id: layer.id).instances
    instances.map { |instance| new(layer, instance, opsworks) }
  end

  def initialize(layer, opsworks_instance, opsworks = Aws::OpsWorks.new(region: "us-east-1"))
    @layer = layer
    @opsworks_instance = opsworks_instance
    @opsworks = opsworks
  end

  def id
    opsworks_instance.instance_id
  end
end
