require "spec_helper"

describe Dumbwaiter::Cli do
  let(:fake_stack) { double(:stack, name: "ducks", stack_id: "cool") }
  let(:fake_stacks) { double(:stacks, stacks: [fake_stack]) }
  let(:custom_json) { {deploy: {"reifel" => {scm: {revision: "corn"}}}} }

  subject(:cli) { Dumbwaiter::Cli.new }

  before { cli.opsworks.stub(describe_stacks: fake_stacks) }

  describe "#deploy" do
    context "when the stack exists" do
      it "deploys the stack with the resolved id" do
        cli.opsworks.should_receive(:create_deployment) do |params|
          params[:stack_id].should == "cool"
          params[:command].should == {name: "deploy", args: {migrate: ["true"]}}
          params[:custom_json].should == custom_json.to_json
        end
        cli.deploy("ducks", "reifel", "corn")
      end
    end

    context "when the stack does not exist" do
      let(:fake_stack) { double(:stack, name: "tacos", stack_id: "great") }

      it "blows up" do
        expect {
          cli.deploy("ducks", "reifel", "corn")
        }.to raise_error(Dumbwaiter::Cli::MissingStack)
      end
    end
  end

  describe "#rollback" do
    context "when the stack exists" do
      it "rolls back the stack with the resolved id" do
        cli.opsworks.should_receive(:create_deployment) do |params|
          params[:stack_id].should == "cool"
          params[:command].should == {name: "rollback"}
        end
        cli.rollback("ducks")
      end
    end

    context "when the stack does not exist" do
      let(:fake_stack) { double(:stack, name: "tacos", stack_id: "great") }

      it "blows up" do
        expect {
          cli.rollback("ducks")
        }.to raise_error(Dumbwaiter::Cli::MissingStack)
      end
    end
  end

  describe "#list" do
    let(:fake_command) { double(:command, name: "deploy", args: "not again!")}
    let(:fake_deployment) { double(:deployment, stack_id: "cool", created_at: "meat", status: "meh", command: fake_command, custom_json: custom_json.to_json) }
    let(:fake_deployments) { double(:deployments, deployments: [fake_deployment]) }

    before { cli.opsworks.stub(describe_deployments: fake_deployments) }

    context "when the stack exists" do
      it "lists the deployments" do
        Kernel.stub(:puts) { |string| string.should =~ /meat.+meh.+corn/ }
        cli.list("ducks")
      end
    end

    context "when the stack does not exist" do
      let(:fake_stack) { double(:stack, name: "tacos", stack_id: "great") }

      it "blows up" do
        expect {
          cli.list("ducks")
        }.to raise_error(Dumbwaiter::Cli::MissingStack)
      end
    end
  end
end
