require "ostruct"
require "faker"

class Dumbwaiter::Mock
  attr_reader :stacks, :deployments, :apps, :layers, :instances, :user_profiles

  class HashWithIndifferentAccess < Hash
    include Hashie::Extensions::MergeInitializer
    include Hashie::Extensions::IndifferentAccess
  end

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
    clear
  end

  def create_stack(params = {})
    params[:name] ||= Faker::Name.first_name
    params[:attributes] ||= {}
    params[:attributes]["Color"] ||= make_color
    stack = OpenStruct.new(params.merge(stack_id: make_id))
    stacks << stack
    stack
  end

  def create_app(params = {})
    params[:stack_id] ||= create_stack.stack_id
    params[:name] ||= Faker::Name.last_name
    params[:shortname] ||= Faker::Name.first_name.downcase
    params[:app_source] = Hashie::Mash.new(params.fetch(:app_source, {}))
    params[:app_source][:url] ||= Faker::Internet.url
    params[:app_source][:revision] = params[:app_source].fetch(:revision, make_revision)
    app = OpenStruct.new(params.merge(app_id: make_id))
    apps << app
    app
  end

  def create_layer(params = {})
    params[:stack_id] ||= create_stack.stack_id
    params[:name] ||= Faker::Name.last_name
    params[:shortname] ||= Faker::Name.first_name.downcase
    params[:custom_recipes] = params[:custom_recipes] || {}
    params[:custom_recipes] = {setup: [], configure: [], deploy: [], undeploy: [], shutdown:[]}.merge(params[:custom_recipes])
    params[:type] ||= %w[lb web php-app rails-app nodejs-app memcached db-master monitoring-master custom].sample
    layer = OpenStruct.new(params.merge(layer_id: make_id))
    layers << layer
    layer
  end

  def create_deployment(params = {})
    params[:stack_id] ||= create_stack.stack_id
    params[:app_id] ||= create_app.app_id
    params[:command] = Hashie::Mash.new(params.fetch(:command, {}))
    params[:command][:name] ||= %w[install_dependencies update_dependencies update_custom_cookbooks execute_recipes deploy rollback start stop restart undeploy].sample
    params[:custom_json] ||= "{}"
    params[:comment] ||= Faker::Company.bs
    params[:iam_user_arn] = params.fetch(:iam_user_arn, create_user_profile.iam_user_arn)
    params[:created_at] ||= Time.now.to_s
    params[:status] ||= %w[running failed successful].sample
    deployment = OpenStruct.new(params.merge(deployment_id: make_id))
    deployments << deployment
    deployment
  end

  def create_instance(params = {})
    params[:stack_id] ||= create_stack.stack_id
    params[:layer_id] ||= create_layer.layer_id
    instance = OpenStruct.new(params.merge(instance_id: make_id))
    instances << instance
    instance
  end

  def create_user_profile(params = {})
    params[:iam_user_arn] ||= Faker::Name.first_name.downcase
    params[:ssh_username] ||= Faker::Name.first_name.downcase
    params[:name] ||= Faker::Name.first_name.downcase
    user_profile = OpenStruct.new(params)
    user_profiles << user_profile
    user_profile
  end

  protected

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
