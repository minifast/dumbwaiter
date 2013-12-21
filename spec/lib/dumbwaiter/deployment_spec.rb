require "spec_helper"

describe Dumbwaiter::Deployment do
  let(:fake_command) { double(:command, name: "deplode") }
  let(:custom_json) { JSON.dump(deploy: {"hockey" => {scm: {revision: "eh-buddy"}}}) }
  let(:fake_deployment) do
    double(:deployment,
      created_at: "last Tuesday",
      command: fake_command,
      status: "badical",
      custom_json: custom_json,
      iam_user_arn: "ie",
      comment: "i love sports"
    )
  end
  let(:fake_deployments) { double(:deployments, deployments: [fake_deployment]) }
  let(:fake_user_profile) { double(:user_profile, name: "goose") }
  let(:fake_user_profiles) { double(:user_profiles, user_profiles: [fake_user_profile]) }
  let(:fake_opsworks) { double(:opsworks, describe_deployments: fake_deployments, describe_user_profiles: fake_user_profiles) }

  subject(:deployment) { Dumbwaiter::Deployment.new(fake_deployment, fake_opsworks) }

  its(:opsworks_deployment) { should == fake_deployment }
  its(:created_at) { should == DateTime.parse("last Tuesday") }
  its(:command_name) { should == "deplode" }
  its(:status) { should == "badical" }
  its(:comment) { should == "i love sports" }
  its(:git_ref) { should == "eh-buddy" }
  its(:to_log) { should == "#{DateTime.parse("last Tuesday")} - goose - deplode - badical - eh-buddy" }
  its(:user_name) { should == "goose" }

  context "when the iam user arn is nil" do
    let(:fake_deployment) do
      double(:deployment,
        created_at: "last Tuesday",
        command: fake_command,
        status: "badical",
        custom_json: custom_json,
        iam_user_arn: nil
      )
    end

    its(:user_name) { should == "?" }
  end

  context "when custom_json is nil" do
    let(:fake_deployment) do
      double(:deployment,
        created_at: "yo",
        command: fake_command,
        status: "badical",
        custom_json: nil
      )
    end

    its(:git_ref) { should == "HEAD" }
  end

  describe ".all" do
    let(:fake_stack) { double(:stack, id: "pancakes") }

    it "fetches all the deployments" do
      fake_opsworks.should_receive(:describe_deployments).with(stack_id: "pancakes")
      Dumbwaiter::Deployment.all(fake_stack, fake_opsworks).should have(1).app
    end
  end
end
