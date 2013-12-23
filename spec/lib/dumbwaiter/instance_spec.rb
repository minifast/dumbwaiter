require "spec_helper"

describe Dumbwaiter::Instance do
  let(:fake_opsworks) { Dumbwaiter::Mock.new }
  let(:fake_stack) { fake_opsworks.make_stack }
  let(:fake_layer) { fake_opsworks.make_layer(fake_stack) }
  let!(:fake_instance) { fake_opsworks.make_instance(fake_stack, fake_layer) }

  subject(:instance) { Dumbwaiter::Instance.new(fake_layer, fake_instance, fake_opsworks) }

  its(:id) { should == fake_instance.instance_id }

  describe ".all" do
    let(:real_layer) { Dumbwaiter::Layer.new(fake_stack, fake_layer, fake_opsworks) }

    it "fetches all the instances" do
      fake_opsworks.should_receive(:describe_instances).with(layer_id: fake_layer.layer_id).and_call_original
      Dumbwaiter::Instance.all(real_layer, fake_opsworks).should have(1).instance
    end
  end
end
