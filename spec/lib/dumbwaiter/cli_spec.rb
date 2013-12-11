require "spec_helper"

describe Dumbwaiter::Cli do
  let(:fake_app) { double(:app, name: "reifel") }
  let(:fake_layer) { double(:layer, shortname: "beans") }
  let(:fake_stack) { double(:stack, name: "ducks", id: "wat", apps: [fake_app]) }

  subject(:cli) { Dumbwaiter::Cli.new }

  before do
    Dumbwaiter::Stack.stub(all: [fake_stack])
    Dumbwaiter::App.stub(all: [fake_app])
    Dumbwaiter::Layer.stub(all: [fake_layer])
  end

  describe "#deploy" do
    context "when the stack exists" do
      context "when the app exists" do
        it "deploys the stack with the resolved id" do
          fake_app.should_receive(:deploy).with("corn")
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
          fake_app.should_receive(:rollback)
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
      before { fake_stack.stub(deployments: [fake_deployment]) }

      context "when the deployment is a rollback" do
        let(:fake_deployment) { double(:deployment, command_name: "rollback", to_log: "oops!") }

        it "lists the deployment" do
          Kernel.should_receive(:puts).with("oops!")
          cli.list("ducks")
        end
      end

      context "when the deployment is a deploy" do
        let(:fake_deployment) { double(:deployment, command_name: "deploy", to_log: "whee!") }

        it "lists the deployment" do
          Kernel.should_receive(:puts).with("whee!")
          cli.list("ducks")
        end
      end

      context "when the deployment is a custom cookbook update" do
        let(:fake_deployment) { double(:deployment, command_name: "update_custom_cookbooks", to_log: "whee!") }

        it "lists the deployment" do
          Kernel.should_receive(:puts).with("whee!")
          cli.list("ducks")
        end
      end

      context "when the deployment is a recipe execution" do
        let(:fake_deployment) { double(:deployment, command_name: "execute_recipes", to_log: "whee!") }

        it "lists the deployment" do
          Kernel.should_receive(:puts).with("whee!")
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
      before { fake_stack.stub(layers: [fake_layer]) }

      it "lists the layers" do
        Kernel.should_receive(:puts).with("beans")
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
        fake_stack.should_receive(:rechef)
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
          fake_layer.should_receive(:run_recipe).with("meatballs")
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
