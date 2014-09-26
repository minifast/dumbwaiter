require "dumbwaiter/deployment_custom_json"
require "dumbwaiter/user_profile"

class Dumbwaiter::Deployment
  attr_reader :stack, :opsworks_deployment, :opsworks

  def self.all(stack, opsworks = Aws::OpsWorks::Client.new(region: "us-east-1"))
    opsworks.describe_deployments(stack_id: stack.id).deployments.map { |d| new(stack, d, opsworks) }
  end

  def initialize(stack, opsworks_deployment, opsworks = Aws::OpsWorks::Client.new(region: "us-east-1"))
    @stack = stack
    @opsworks_deployment = opsworks_deployment
    @opsworks = opsworks
  end

  def created_at
    DateTime.parse(opsworks_deployment.created_at)
  end

  def command_name
    opsworks_deployment.command.name
  end

  def comment
    opsworks_deployment.comment
  end

  def status
    opsworks_deployment.status
  end

  def user_name
    if user_profile.nil?
      "OpsWorks"
    else
      user_profile.name
    end
  end

  def revision
    deployment_custom_json.revision || "#{app.revision}@{#{created_at}}"
  end

  def to_log
    if command_name == "deploy"
      "#{created_at} - #{user_name} - #{command_name} - #{status} - #{revision}"
    else
      "#{created_at} - #{user_name} - #{command_name} - #{status}"
    end
  end

  protected

  def app
    Dumbwaiter::App.find_by_id(stack, opsworks_deployment.app_id, opsworks)
  end

  def user_profile
    Dumbwaiter::UserProfile.find(opsworks_deployment.iam_user_arn, opsworks)
  end

  def deployment_custom_json
    Dumbwaiter::DeploymentCustomJson.from_json(custom_json)
  end

  def custom_json
    opsworks_deployment.custom_json || "{}"
  end
end
