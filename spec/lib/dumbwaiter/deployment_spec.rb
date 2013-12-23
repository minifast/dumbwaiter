require "spec_helper"

describe Dumbwaiter::Deployment do
  let(:fake_opsworks) { Dumbwaiter::Mock.new }
  let(:fake_stack) { fake_opsworks.make_stack("pancakes") }
  let(:fake_app) { fake_opsworks.make_app(fake_stack, "yo") }
  let!(:fake_user_profile) { fake_opsworks.make_user_profile("ie", "goose") }
  let(:custom_json) { Dumbwaiter::DeploymentCustomJson.create("hockey", "eh-buddy").to_json }
  let!(:fake_deployment) { fake_opsworks.make_deployment(fake_stack, fake_app, "jello", "deploy", "badical", custom_json, DateTime.parse("last Tuesday").to_s, "ie", "i love sports") }
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
    let!(:fake_deployment) { fake_opsworks.make_deployment(fake_stack, fake_app, "jello", "floss", "badical", custom_json, DateTime.parse("last Tuesday").to_s, "ie", "i love sports") }

    its(:to_log) { should == "#{DateTime.parse("last Tuesday")} - goose - floss - badical" }
  end

  context "when the iam user arn is nil" do
    let!(:fake_deployment) { fake_opsworks.make_deployment(fake_stack, fake_app, "jello", "deploy", "badical", custom_json, DateTime.parse("last Tuesday").to_s, nil, "i love sports") }

    its(:user_name) { should == "OpsWorks" }
  end

  context "when the iam user arn does not exist" do
    let!(:fake_deployment) { fake_opsworks.make_deployment(fake_stack, fake_app, "jello", "deploy", "badical", custom_json, DateTime.parse("last Tuesday").to_s, "wait which user is this", "i love sports") }

    before { fake_opsworks.clear }

    its(:user_name) { should == "OpsWorks" }
  end

  context "when custom_json is nil" do
    let(:real_app) { Dumbwaiter::App.new(real_stack, fake_app, fake_opsworks) }
    let!(:fake_deployment) { fake_opsworks.make_deployment(fake_stack, fake_app, "jello", "deploy", "badical", nil, DateTime.parse("last Tuesday").to_s, "ie", "i love sports") }

    its(:revision) { should == "#{real_app.revision}@{#{DateTime.parse("last Tuesday")}}" }
  end

  describe ".all" do
    it "fetches all the deployments" do
      fake_opsworks.should_receive(:describe_deployments).with(stack_id: "pancakes").and_call_original
      Dumbwaiter::Deployment.all(real_stack, fake_opsworks).should have(1).deployment
    end
  end
end
