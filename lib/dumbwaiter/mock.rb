require "faker"

class Dumbwaiter::Mock
  attr_reader :stacks, :deployments, :apps, :layers, :instances, :user_profiles

  def opsworks; self; end
  def describe_stacks(*_); OpenStruct.new(stacks: stacks); end
  def describe_deployments(*_); OpenStruct.new(deployments: deployments); end
  def describe_apps(*_); OpenStruct.new(apps: apps); end
  def describe_layers(*_); OpenStruct.new(layers: layers); end
  def describe_instances(*_); OpenStruct.new(instances: instances); end
  def describe_user_profiles(*_); OpenStruct.new(user_profiles: user_profiles); end

  def clear
    @stacks = []
    @deployments = []
    @apps = []
    @layers = []
    @instances = []
    @user_profiles = []
  end

  def initialize
    super
    clear
  end

  def make_stack(id = make_id, name = Faker::Name.first_name, color = make_color)
    stack = OpenStruct.new(stack_id: id, name: name, attributes: {"Color" => color})
    stacks << stack
    stack
  end

  def make_app(stack = make_stack, id = make_id, name = Faker::Name.first_name, url = Faker::Internet.url, revision = make_revision)
    app = OpenStruct.new(stack_id: stack.stack_id, app_id: id, name: name, app_source: make_app_source(url, revision))
    apps << app
    app
  end

  def make_layer(stack = make_stack, id = make_id, shortname = Faker::Name.first_name.downcase, custom_recipes = {})
    layer = OpenStruct.new(stack_id: stack.stack_id, layer_id: id, shortname: shortname, custom_recipes: make_custom_default_recipes.merge(custom_recipes))
    layers << layer
    layer
  end

  def make_deployment(stack = make_stack, app = make_app, id = make_id, command_name = Faker::Name.first_name.downcase, status = Faker::Name.first_name, custom_json = "{}", at = Time.now.to_s, arn = Faker::Name.first_name, comment = Faker::Company.bs)
    command = OpenStruct.new(name: command_name)
    deployment = OpenStruct.new(stack_id: stack.stack_id, app_id: app.app_id, deployment_id: id, command: command, created_at: at, status: status, comment: comment, iam_user_arn: arn, custom_json: custom_json)
    deployments << deployment
    deployment
  end

  def make_instance(stack = make_stack, layer = make_layer, id = make_id)
    instance = OpenStruct.new(layer_id: layer.layer_id, stack_id: stack.stack_id, instance_id: id)
    instances << instance
    instance
  end

  def make_user_profile(id = Faker::Name.last_name.downcase, name = Faker::Name.first_name)
    user_profile = OpenStruct.new(aws_iam_arn: id, name: name)
    user_profiles << user_profile
    user_profile
  end

  protected

  def make_custom_default_recipes
    {setup: [], configure: [], deploy: [], undeploy: [], shutdown:[]}
  end

  def make_app_source(url, revision)
    OpenStruct.new(url: url, revision: revision)
  end

  def make_revision
    "%06x" % (rand * 0xffffff)
  end

  def make_color
    "rgb(#{rand(255)},#{rand(255)},#{rand(255)})"
  end

  def make_id
    @id ||= 0
    @id += 1
    "taco-#{@id}"
  end
end
