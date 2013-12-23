require "spec_helper"

describe Dumbwaiter::Layer do
  let(:fake_opsworks) { Dumbwaiter::Mock.new }
  let(:fake_stack) { fake_opsworks.make_stack("pancakes") }
  let(:fake_layer) { fake_opsworks.make_layer(fake_stack, "pinto", "meaty") }
  let!(:fake_instance) { fake_opsworks.make_instance(fake_layer, fake_stack, "dragons") }

  let(:real_stack) { Dumbwaiter::Stack.new(fake_stack, fake_opsworks) }

  subject(:layer) { Dumbwaiter::Layer.new(real_stack, fake_layer, fake_opsworks) }

  its(:opsworks_layer) { should == fake_layer }
  its(:id) { should == "pinto" }
  its(:shortname) { should == "meaty" }

  it { should have(1).instances }

  describe ".all" do
    let(:real_stack) { Dumbwaiter::Stack.new(fake_stack, fake_opsworks) }

    it "fetches all the deployments" do
      fake_opsworks.should_receive(:describe_layers).with(stack_id: "pancakes").and_call_original
      Dumbwaiter::Layer.all(real_stack, fake_opsworks).should have(1).layer
    end
  end

  describe ".find" do
    context "when the layer exists" do
      it "finds the layer by name" do
        Dumbwaiter::Layer.find(real_stack, "meaty", fake_opsworks).shortname.should == "meaty"
      end
    end

    context "when the layer does not exist" do
      it "blows up" do
        expect {
          Dumbwaiter::Layer.find(real_stack, "brick", fake_opsworks)
        }.to raise_error(Dumbwaiter::Layer::NotFound)
      end
    end
  end

  describe "#run_recipe" do
    it "executes a recipe" do
      fake_opsworks.should_receive(:create_deployment) do |params|
        params[:stack_id].should == "pancakes"
        params[:instance_ids].should == ["dragons"]
        params[:command].should == {name: "execute_recipes", args: {recipes: ["meatballs"]}}
      end
      layer.run_recipe("meatballs")
    end
  end
end
