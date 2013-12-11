require "spec_helper"

describe Dumbwaiter::Layer do
  let(:fake_stack) { double(:stack, id: "pancakes") }
  let(:fake_layer) { double(:layer, shortname: "meaty", layer_id: "pinto") }
  let(:fake_layers) { double(:layers, layers: [fake_layer]) }
  let(:fake_instance) { double(:instance, id: "dragons") }
  let(:fake_instances) { double(:instances, instances: [fake_instance]) }
  let(:fake_opsworks) { double(:opsworks, describe_layers: fake_layers, describe_instances: fake_instances) }

  before do
    Dumbwaiter::Instance.stub(all: [fake_instance])
  end

  subject(:layer) { Dumbwaiter::Layer.new(fake_stack, fake_layer, fake_opsworks) }

  its(:opsworks_layer) { should == fake_layer }
  its(:id) { should == "pinto" }
  its(:shortname) { should == "meaty" }

  its(:instances) { should == [fake_instance] }

  describe ".all" do
    it "fetches all the deployments" do
      fake_opsworks.should_receive(:describe_layers).with(stack_id: "pancakes")
      Dumbwaiter::Layer.all(fake_stack, fake_opsworks).should have(1).layer
    end
  end

  describe ".find" do
    context "when the layer exists" do
      it "finds the layer by name" do
        Dumbwaiter::Layer.find(fake_stack, "meaty", fake_opsworks).shortname.should == "meaty"
      end
    end

    context "when the layer does not exist" do
      it "blows up" do
        expect {
          Dumbwaiter::Layer.find(fake_stack, "brick", fake_opsworks)
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
