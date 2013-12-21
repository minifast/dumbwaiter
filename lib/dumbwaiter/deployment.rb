require "dumbwaiter/deployment_custom_json"
require "dumbwaiter/user_profile"

class Dumbwaiter::Deployment
  attr_reader :opsworks_deployment, :opsworks

  def self.all(stack, opsworks = Aws::OpsWorks.new(region: "us-east-1"))
    opsworks.describe_deployments(stack_id: stack.id).deployments.map { |d| new(d, opsworks) }
  end

  def initialize(opsworks_deployment, opsworks)
    @opsworks_deployment = opsworks_deployment
    @opsworks = opsworks
  end

  def created_at
    DateTime.parse(opsworks_deployment.created_at)
  end

  def command_name
    opsworks_deployment.command.name
  end

  def status
    opsworks_deployment.status
  end

  def user_name
    user_profile.name
  end

  def git_ref
    deployment_custom_json.git_ref
  end

  def to_log
    "#{created_at} - #{command_name} - #{status} - #{git_ref}"
  end

  protected

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
