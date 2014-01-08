require "spec_helper"

describe Dumbwaiter::Stack do
  let(:fake_opsworks) { Dumbwaiter::Mock.new }
  let!(:fake_stack) { fake_opsworks.create_stack(name: "ducks", attributes:{"Color" => "hot pink"}) }
  let!(:fake_app) { fake_opsworks.create_app(stack_id: fake_stack.stack_id) }
  let!(:fake_deployment) { fake_opsworks.create_deployment(stack_id: fake_stack.stack_id, app_id: fake_app.app_id) }
  let!(:fake_layer) { fake_opsworks.create_layer(stack_id: fake_stack.stack_id) }

  subject(:stack) { Dumbwaiter::Stack.new(fake_stack, fake_opsworks) }

  it { should have(1).apps }
  it { should have(1).deployments }
  it { should have(1).layers }

  its(:id) { should == fake_stack.stack_id }
  its(:name) { should == "ducks" }
  its(:color) { should == "hot pink" }

  describe ".all" do
    it "fetches all the stacks" do
      Dumbwaiter::Stack.all(fake_opsworks).should have(1).stack
    end
  end

  describe ".find" do
    context "when the stack exists" do
      it "finds the stack by name" do
        Dumbwaiter::Stack.find("ducks", fake_opsworks).id.should == fake_stack.stack_id
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

  describe ".find_by_id" do
    context "when the stack exists" do
      it "finds the stack by id" do
        Dumbwaiter::Stack.find_by_id(fake_stack.stack_id, fake_opsworks).name.should == "ducks"
      end
    end

    context "when the stack does not exist" do
      it "blows up" do
        expect {
          Dumbwaiter::Stack.find_by_id("teeth", fake_opsworks)
        }.to raise_error(Dumbwaiter::Stack::NotFound)
      end
    end
  end

  describe "#rechef" do
    it "creates a deployment" do
      fake_opsworks.should_receive(:create_deployment) do |params|
        params[:stack_id].should == fake_stack.stack_id
        params[:command].should == {name: "update_custom_cookbooks"}
      end
      stack.rechef
    end
  end
end
