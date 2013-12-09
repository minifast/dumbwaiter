require "spec_helper"

describe Dumbwaiter::Stack do
  let(:fake_stack) { double(:stack, name: "ducks", stack_id: "cool") }
  let(:fake_stacks) { double(:stacks, stacks: [fake_stack]) }
  let(:fake_opsworks) { double(:opsworks, describe_stacks: fake_stacks) }
  let(:fake_app) { double(:app) }
  let(:fake_deployment) { double(:deployment) }

  subject(:stack) { Dumbwaiter::Stack.new(fake_stack) }

  before do
    Dumbwaiter::App.stub(all: [fake_app])
    Dumbwaiter::Deployment.stub(all: [fake_deployment])
  end

  its(:opsworks_stack) { should == fake_stack }
  its(:id) { should == "cool" }
  its(:name) { should == "ducks" }

  its(:apps) { should == [fake_app] }
  its(:deployments) { should == [fake_deployment] }

  describe ".all" do
    it "fetches all the stacks" do
      Dumbwaiter::Stack.all(fake_opsworks).should have(1).stack
    end
  end

  describe ".find" do
    context "when the stack exists" do
      it "finds the stack by name" do
        Dumbwaiter::Stack.find("ducks", fake_opsworks).id.should == "cool"
      end
    end

    context "when the stack does not exist" do
      it "blows up" do
        expect {
          Dumbwaiter::Stack.find("teeth", fake_opsworks)
        }.to raise_error(Dumbwaiter::Stack::NotFound)
      end
    end
  end
end