require "spec_helper"

describe Dumbwaiter::Deployment do
  let(:fake_opsworks) { Dumbwaiter::Mock.new }
  let(:fake_stack) { fake_opsworks.create_stack }
  let(:fake_app) { fake_opsworks.create_app(stack_id: fake_stack.stack_id) }
  let!(:fake_user_profile) { fake_opsworks.create_user_profile(name: "goose") }
  let(:custom_json) { Dumbwaiter::DeploymentCustomJson.create("hockey", "eh-buddy").to_json }
  let(:deployment_params) do
    {
      command: {name: "deploy"},
      status: "badical",
      comment: "i love sports",
      created_at: DateTime.parse("last Tuesday").to_s
    }
  end

  let!(:fake_deployment) do
    fake_opsworks.create_deployment({
      iam_user_arn: fake_user_profile.iam_user_arn,
      stack_id: fake_stack.stack_id,
      app_id: fake_app.app_id,
      custom_json: custom_json
    }.merge(deployment_params))
  end
  let(:real_stack) { Dumbwaiter::Stack.new(fake_stack, fake_opsworks) }

  subject(:deployment) { Dumbwaiter::Deployment.new(real_stack, fake_deployment, fake_opsworks) }

  its(:created_at) { should == DateTime.parse("last Tuesday") }
  its(:command_name) { should == "deploy" }
  its(:status) { should == "badical" }
  its(:comment) { should == "i love sports" }
  its(:revision) { should == "eh-buddy" }
  its(:user_name) { should == "goose" }

  context "when the command name is deploy" do
    its(:to_log) { should == "#{DateTime.parse("last Tuesday")} - goose - deploy - badical - eh-buddy" }
  end

  context "when the command name is not deploy" do
    let(:deployment_params) do
      {
        command: {name: "floss"},
        status: "badical",
        created_at: DateTime.parse("last Tuesday").to_s
      }
    end

    its(:to_log) { should == "#{DateTime.parse("last Tuesday")} - goose - floss - badical" }
  end

  context "when the iam user does not exist" do
    let(:deployment_params) do
      {
        command: {name: "floss"},
        status: "badical",
        created_at: DateTime.parse("last Tuesday").to_s,
        iam_user_arn: nil
      }
    end

    its(:user_name) { should == "OpsWorks" }
  end

  context "when custom_json is nil" do
    let(:real_app) { Dumbwaiter::App.new(real_stack, fake_app, fake_opsworks) }
    let(:deployment_params) do
      {
        command: {name: "floss"},
        status: "badical",
        created_at: DateTime.parse("last Tuesday").to_s,
        custom_json: nil
      }
    end

    its(:revision) { should == "#{real_app.revision}@{#{DateTime.parse("last Tuesday")}}" }
  end

  describe ".all" do
    it "fetches all the deployments" do
      fake_opsworks.should_receive(:describe_deployments).with(stack_id: fake_stack.stack_id).and_call_original
      Dumbwaiter::Deployment.all(real_stack, fake_opsworks).should have(1).deployment
    end
  end
end
