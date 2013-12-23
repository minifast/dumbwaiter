require "spec_helper"

describe Dumbwaiter::Cli do
  let(:fake_opsworks) { Dumbwaiter::Mock.new }
  let!(:fake_stack) { fake_opsworks.make_stack("amazing", "ducks") }
  let!(:fake_layer) { fake_opsworks.make_layer(fake_stack, "mighty", "beans") }
  let!(:fake_app) { fake_opsworks.make_app(fake_stack, "delightful", "reifel") }

  subject(:cli) { Dumbwaiter::Cli.new }

  before { Aws::OpsWorks.stub(new: fake_opsworks) }

  describe "#deploy" do
    context "when the stack exists" do
      context "when the app exists" do
        it "deploys the stack with the resolved id" do
          Dumbwaiter::App.any_instance.should_receive(:deploy).with("corn")
          cli.deploy("ducks", "reifel", "corn")
        end
      end

      context "when the app does not exist" do
        it "blows up" do
          expect { cli.deploy("ducks", "squirrel", "corn") }.to raise_error(Thor::Error)
        end
      end
    end

    context "when the stack does not exist" do
      it "blows up" do
        expect { cli.deploy("toques", "reifel", "corn") }.to raise_error(Thor::Error)
      end
    end
  end

  describe "#rollback" do
    context "when the stack exists" do
      context "when the app exists" do
        it "deploys the stack with the resolved id" do
          Dumbwaiter::App.any_instance.should_receive(:rollback)
          cli.rollback("ducks", "reifel")
        end
      end

      context "when the app does not exist" do
        it "blows up" do
          expect { cli.rollback("ducks", "montreal") }.to raise_error(Thor::Error)
        end
      end
    end

    context "when the stack does not exist" do
      it "blows up" do
        expect { cli.rollback("maple syrup", "reifel") }.to raise_error(Thor::Error)
      end
    end
  end

  describe "#list" do
    context "when the stack exists" do
      context "when the deployment is a rollback" do
        before { fake_opsworks.make_deployment(fake_stack, fake_app, "jello", "rollback") }

        it "lists the deployment" do
          Kernel.should_receive(:puts) { |m| m.should =~ /rollback/ }
          cli.list("ducks")
        end
      end

      context "when the deployment is a deploy" do
        before { fake_opsworks.make_deployment(fake_stack, fake_app, "jello", "deploy") }

        it "lists the deployment" do
          Kernel.should_receive(:puts) { |m| m.should =~ /deploy/ }
          cli.list("ducks")
        end
      end

      context "when the deployment is a custom cookbook update" do
        before { fake_opsworks.make_deployment(fake_stack, fake_app, "jello", "update_custom_cookbooks") }

        it "lists the deployment" do
          Kernel.should_receive(:puts) { |m| m.should =~ /update_custom_cookbooks/ }
          cli.list("ducks")
        end
      end

      context "when the deployment is a recipe execution" do
        before { fake_opsworks.make_deployment(fake_stack, fake_app, "jello", "execute_recipes") }

        it "lists the deployment" do
          Kernel.should_receive(:puts) { |m| m.should =~ /execute_recipes/ }
          cli.list("ducks")
        end
      end

      context "when the deployment is something else" do
        let(:fake_deployment) { double(:deployment, command_name: "gargle", to_log: "brblrgl") }

        it "does not print anything" do
          Kernel.should_not_receive(:puts)
          cli.list("ducks")
        end
      end
    end

    context "when the stack does not exist" do
      it "blows up" do
        expect { cli.list("wat") }.to raise_error(Thor::Error)
      end
    end
  end

  describe "#layers" do
    context "when the stack exists" do
      it "lists the layers" do
        Kernel.should_receive(:puts).with(fake_layer.shortname)
        cli.layers("ducks")
      end
    end

    context "when the stack does not exist" do
      it "blows up" do
        expect { cli.layers("wat") }.to raise_error(Thor::Error)
      end
    end
  end

  describe "#rechef" do
    context "when the stack exists" do
      it "deploys the stack with the resolved id" do
        Dumbwaiter::Stack.any_instance.should_receive(:rechef)
        cli.rechef("ducks")
      end
    end

    context "when the stack does not exist" do
      it "blows up" do
        expect { cli.rechef("toques") }.to raise_error(Thor::Error)
      end
    end
  end

  describe "#run_recipe" do
    context "when the stack exists" do
      context "when the layer exists" do
        it "runs the recipe on the layer" do
          Dumbwaiter::Layer.any_instance.should_receive(:run_recipe).with("meatballs")
          cli.run_recipe("ducks", "beans", "meatballs")
        end
      end

      context "when the layer does not exist" do
        it "blows up" do
          expect { cli.run_recipe("ducks", "brick", "meatballs") }.to raise_error(Thor::Error)
        end
      end
    end

    context "when the stack does not exist" do
      it "blows up" do
        expect { cli.run_recipe("toques", "beans", "meatballs") }.to raise_error(Thor::Error)
      end
    end
  end

  describe "#stacks" do
    it "lists the stacks" do
      Kernel.should_receive(:puts).with("ducks: reifel")
      cli.stacks
    end
  end
end
