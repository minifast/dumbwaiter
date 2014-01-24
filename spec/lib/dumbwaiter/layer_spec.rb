require "spec_helper"

describe Dumbwaiter::Layer do
  let(:fake_opsworks) { Dumbwaiter::Mock.new }
  let(:fake_stack) { fake_opsworks.create_stack }
  let(:fake_custom_recipes) { {setup: ["ham"]} }
  let(:fake_layer) { fake_opsworks.create_layer(stack_id: fake_stack.stack_id, shortname: "meaty", custom_recipes: fake_custom_recipes) }
  let!(:fake_instance) { fake_opsworks.create_instance }

  let(:real_stack) { Dumbwaiter::Stack.new(fake_stack, fake_opsworks) }

  subject(:layer) { Dumbwaiter::Layer.new(real_stack, fake_layer, fake_opsworks) }

  its(:opsworks_layer) { should == fake_layer }
  its(:id) { should == fake_layer.layer_id }
  its(:shortname) { should == "meaty" }
  its(:custom_recipes) { should include(setup: ["ham"]) }

  it { should have(1).instances }

  describe ".all" do
    let(:real_stack) { Dumbwaiter::Stack.new(fake_stack, fake_opsworks) }

    it "fetches all the deployments" do
      fake_opsworks.should_receive(:describe_layers).with(stack_id: fake_stack.stack_id).and_call_original
      Dumbwaiter::Layer.all(real_stack, fake_opsworks).should have(1).layer
    end
  end

  describe ".find" do
    context "when the layer exists" do
      let!(:layer) { Dumbwaiter::Layer.new(real_stack, fake_layer, fake_opsworks) }

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
        params[:stack_id].should == fake_stack.stack_id
        params[:instance_ids].should == [fake_instance.instance_id]
        params[:command].should == {name: "execute_recipes", args: {recipes: ["meatballs"]}}
      end
      layer.run_recipe("meatballs")
    end

    it "executes multiple recipes" do
      fake_opsworks.should_receive(:create_deployment) do |params|
        params[:command][:args][:recipes].should == %w[
          horrifying::salad regrettable::potatoes
        ]
      end
      layer.run_recipe("horrifying::salad", "regrettable::potatoes")
    end
  end

  describe "#update_custom_recipes" do
    it "overwrites existing custom recipes for an event" do
      fake_opsworks.should_receive(:update_layer) do |params|
        params[:layer_id].should == fake_layer.layer_id
        params[:custom_recipes].should include(setup: ["feet"])
      end
      layer.update_custom_recipes(:setup, ["feet"])
    end

    it "preserves existing custom recipes for an event when updating another event" do
      fake_opsworks.should_receive(:update_layer) do |params|
        params[:custom_recipes].should include(setup: ["ham"])
      end
      layer.update_custom_recipes(:deploy, ["feet"])
    end
  end
end
