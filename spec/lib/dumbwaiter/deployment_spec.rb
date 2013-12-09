require "spec_helper"

describe Dumbwaiter::Deployment do
  let(:fake_command) { double(:command, name: "deplode") }
  let(:custom_json) { JSON.dump(deploy: {"hockey" => {scm: {revision: "eh-buddy"}}}) }
  let(:fake_deployment) do
    double(:deployment,
      created_at: "yo",
      command: fake_command,
      status: "badical",
      custom_json: custom_json
    )
  end
  let(:fake_deployments) { double(:deployments, deployments: [fake_deployment]) }
  let(:fake_opsworks) { double(:opsworks, describe_deployments: fake_deployments) }

  subject(:deployment) { Dumbwaiter::Deployment.new(fake_deployment) }

  its(:opsworks_deployment) { should == fake_deployment }
  its(:created_at) { should == "yo" }
  its(:command_name) { should == "deplode" }
  its(:status) { should == "badical" }
  its(:git_ref) { should == "eh-buddy" }
  its(:to_log) { should == "yo - deplode - badical - eh-buddy" }

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
    it "fetches all the deployments" do
      fake_opsworks.should_receive(:describe_deployments).with(stack_id: "pancakes")
      Dumbwaiter::Deployment.all("pancakes", fake_opsworks).should have(1).app
    end
  end
end