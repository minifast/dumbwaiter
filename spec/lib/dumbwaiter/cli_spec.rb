require "spec_helper"

describe Dumbwaiter::Cli do
  subject(:cli) { Dumbwaiter::Cli.new }

  describe "#deploy" do
    context "when the stack exists" do
      before { cli.opsworks.stub(describe_stacks: [{name: "ducks", stack_id: "cool"}]) }

      it "deploys the stack with the resolved id" do
        cli.opsworks.should_receive(:create_deployment) do |params|
          params[:stack_id].should == "cool"
          params[:command].should == {name: "deploy"}
          params[:custom_json].should == {deploy: {"reifel" => {scm: {revision: "corn"}}}}.to_json
        end
        cli.deploy("ducks", "reifel", "corn")
      end
    end

    context "when the stack does not exist" do
      before { cli.opsworks.stub(describe_stacks: [{name: "tacos", stack_id: "great"}]) }

      it "blows up" do
        expect { cli.deploy("ducks", "reifel", "corn") }.to raise_error(Dumbwaiter::Cli::MissingStack)
      end
    end
  end

  describe "#rollback" do
    context "when the stack exists" do
      before { cli.opsworks.stub(describe_stacks: [{name: "ducks", stack_id: "cool"}]) }

      it "rolls back the stack with the resolved id" do
        cli.opsworks.should_receive(:create_deployment) do |params|
          params[:stack_id].should == "cool"
          params[:command].should == {name: "rollback"}
        end
        cli.rollback("ducks")
      end
    end

    context "when the stack does not exist" do
      before { cli.opsworks.stub(describe_stacks: [{name: "tacos", stack_id: "great"}]) }

      it "blows up" do
        expect { cli.rollback("ducks") }.to raise_error(Dumbwaiter::Cli::MissingStack)
      end
    end
  end

  describe "#list" do
    context "when the stack exists" do
      before do
        cli.opsworks.stub(
          describe_stacks: [{name: "ducks", stack_id: "cool"}],
          describe_deployments: [{stack_id: "cool", created_at: "meat", status: "meh", custom_json: {deploy: {"reifel" => {scm: {revision: "corn"}}}}.to_json}]
        )
      end

      it "lists the deployments" do
        Kernel.stub(:puts) { |string| string.should =~ /meat.+corn.+meh/ }
        cli.list("ducks")
      end
    end

    context "when the stack does not exist" do
      before { cli.opsworks.stub(describe_stacks: [{name: "tacos", stack_id: "great"}]) }

      it "blows up" do
        expect { cli.list("ducks") }.to raise_error(Dumbwaiter::Cli::MissingStack)
      end
    end
  end
end
