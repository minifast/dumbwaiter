require "spec_helper"

describe Dumbwaiter::Cli do
  let(:fake_opsworks) { Dumbwaiter::Mock.new }
  let!(:fake_stack) { fake_opsworks.create_stack }
  let!(:fake_layer) { fake_opsworks.create_layer(stack_id: fake_stack.stack_id, custom_recipes: {setup: %w[ham salami]}) }
  let!(:fake_app) { fake_opsworks.create_app(stack_id: fake_stack.stack_id) }

  subject(:cli) { Dumbwaiter::Cli.new }

  before { Aws::OpsWorks::Client.stub(new: fake_opsworks) }

  describe "#deploy" do
    context "when the stack exists" do
      context "when the app exists" do
        it "deploys the stack with the resolved id" do
          Dumbwaiter::App.any_instance.should_receive(:deploy).with("corn")
          cli.deploy(fake_stack.name, fake_app.name, "corn")
        end
      end

      context "when the app does not exist" do
        it "blows up" do
          expect { cli.deploy(fake_stack.name, "squirrel", "corn") }.to raise_error(Thor::Error)
        end
      end
    end

    context "when the stack does not exist" do
      it "blows up" do
        expect { cli.deploy("toques", fake_app.name, "corn") }.to raise_error(Thor::Error)
      end
    end
  end

  describe "#rollback" do
    context "when the stack exists" do
      context "when the app exists" do
        it "deploys the stack with the resolved id" do
          Dumbwaiter::App.any_instance.should_receive(:rollback)
          cli.rollback(fake_stack.name, fake_app.name)
        end
      end

      context "when the app does not exist" do
        it "blows up" do
          expect { cli.rollback(fake_stack.name, "montreal") }.to raise_error(Thor::Error)
        end
      end
    end

    context "when the stack does not exist" do
      it "blows up" do
        expect { cli.rollback("maple syrup", fake_app.name) }.to raise_error(Thor::Error)
      end
    end
  end

  describe "#list" do
    context "when the stack exists" do
      context "when the deployment is a rollback" do
        before { fake_opsworks.create_deployment(stack_id: fake_stack.stack_id, command: {name: "rollback"}) }

        it "lists the deployment" do
          Kernel.should_receive(:puts) { |m| m.should =~ /rollback/ }
          cli.list(fake_stack.name)
        end
      end

      context "when the deployment is a deploy" do
        before { fake_opsworks.create_deployment(stack_id: fake_stack.stack_id, command: {name: "deploy"}) }

        it "lists the deployment" do
          Kernel.should_receive(:puts) { |m| m.should =~ /deploy/ }
          cli.list(fake_stack.name)
        end
      end

      context "when the deployment is a custom cookbook update" do
        before { fake_opsworks.create_deployment(stack_id: fake_stack.stack_id, command: {name: "update_custom_cookbooks"}) }

        it "lists the deployment" do
          Kernel.should_receive(:puts) { |m| m.should =~ /update_custom_cookbooks/ }
          cli.list(fake_stack.name)
        end
      end

      context "when the deployment is a recipe execution" do
        before { fake_opsworks.create_deployment(stack_id: fake_stack.stack_id, command: {name: "execute_recipes"}) }

        it "lists the deployment" do
          Kernel.should_receive(:puts) { |m| m.should =~ /execute_recipes/ }
          cli.list(fake_stack.name)
        end
      end

      context "when the deployment is something else" do
        before { fake_opsworks.create_deployment(stack_id: fake_stack.stack_id, command: {name: "wat"}) }

        it "does not print anything" do
          Kernel.should_not_receive(:puts)
          cli.list(fake_stack.name)
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
      before { fake_opsworks.create_layer(stack_id: fake_stack.stack_id, shortname: "frijoles") }

      it "lists the layers" do
        Kernel.should_receive(:puts).with("#{fake_layer.shortname} frijoles")
        cli.layers(fake_stack.name)
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
        cli.rechef(fake_stack.name)
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
          cli.run_recipe(fake_stack.name, fake_layer.shortname, "meatballs")
        end
      end

      context "when the layer does not exist" do
        it "blows up" do
          expect { cli.run_recipe(fake_stack.name, "brick", "setup") }.to raise_error(Thor::Error)
        end
      end
    end

    context "when the stack does not exist" do
      it "blows up" do
        expect { cli.run_recipe("toques", fake_layer.shortname, "setup") }.to raise_error(Thor::Error)
      end
    end
  end

  describe "#custom_recipes" do
    context "when the stack exists" do
      context "when the layer exists" do
        it "prints custom recipes for a layer event" do
          Kernel.should_receive(:puts).with("ham salami")
          cli.custom_recipes(fake_stack.name, fake_layer.shortname, "setup")
        end
      end

      context "when the layer does not exist" do
        it "blows up" do
          expect { cli.custom_recipes(fake_stack.name, "brick", "setup") }.to raise_error(Thor::Error)
        end
      end
    end

    context "when the stack does not exist" do
      it "blows up" do
        expect { cli.custom_recipes("toques", fake_layer.shortname, "setup") }.to raise_error(Thor::Error)
      end
    end
  end

  describe "#update_custom_recipes" do
    context "when the stack exists" do
      context "when the layer exists" do
        it "updates custom recipes on the layer for the event" do
          Dumbwaiter::Layer.any_instance.should_receive(:update_custom_recipes).with(:setup, ["eggs"])
          cli.update_custom_recipes(fake_stack.name, fake_layer.shortname, "setup", "eggs")
        end
      end

      context "when the layer does not exist" do
        it "blows up" do
          expect { cli.update_custom_recipes(fake_stack.name, "brick", "meatballs") }.to raise_error(Thor::Error)
        end
      end
    end

    context "when the stack does not exist" do
      it "blows up" do
        expect { cli.update_custom_recipes("toques", fake_layer.shortname, "meatballs") }.to raise_error(Thor::Error)
      end
    end
  end

  describe "#stacks" do
    it "lists the stacks" do
      Kernel.should_receive(:puts).with("#{fake_stack.name}: #{fake_app.name}")
      cli.stacks
    end
  end
end
