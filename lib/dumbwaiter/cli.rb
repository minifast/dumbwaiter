require "thor"
require "aws-sdk-core"
require "dumbwaiter/deployment_custom_json"
require "dumbwaiter/stack"

module Dumbwaiter
  class Cli < Thor
    desc "deploy STACK APP GIT_REF", "Deploy an application revision"
    def deploy(stack_name, app_name, revision)
      stack = Stack.find(stack_name)
      app = App.find(stack, app_name)
      app.deploy(revision)
    rescue Dumbwaiter::Stack::NotFound, Dumbwaiter::App::NotFound => e
      raise Thor::Error.new(e.message)
    end

    desc "list STACK", "List all the deployments for a stack"
    def list(stack_name)
      stack = Stack.find(stack_name)

      deployments = stack.deployments.select do |deployment|
        %w(rollback deploy update_custom_cookbooks execute_recipes).include?(deployment.command_name)
      end

      deployments.each do |deployment|
        Kernel.puts(deployment.to_log)
      end
    rescue Dumbwaiter::Stack::NotFound => e
      raise Thor::Error.new(e.message)
    end

    desc "rechef STACK", "Upload new cookbooks to a stack"
    def rechef(stack_name)
      Stack.find(stack_name).rechef
    rescue Dumbwaiter::Stack::NotFound => e
      raise Thor::Error.new(e.message)
    end

    desc "rollback STACK APP", "Roll back an application"
    def rollback(stack_name, app_name)
      stack = Stack.find(stack_name)
      app = App.find(stack, app_name)
      app.rollback
    rescue Dumbwaiter::Stack::NotFound, Dumbwaiter::App::NotFound => e
      raise Thor::Error.new(e.message)
    end

    desc "run_recipe STACK LAYER RECIPE", "Run a recipe against a stack's layer"
    def run_recipe(stack_name, layer_name, recipe)
      stack = Stack.find(stack_name)
      layer = Layer.find(stack, layer_name)
      layer.run_recipe(recipe)
    rescue Dumbwaiter::Stack::NotFound, Dumbwaiter::Layer::NotFound => e
      raise Thor::Error.new(e.message)
    end

    desc "custom_recipes STACK LAYER EVENT", "Show custom recipes for an event"
    def custom_recipes(stack_name, layer_name, event_name)
      stack = Stack.find(stack_name)
      layer = Layer.find(stack, layer_name)
      recipes = layer.custom_recipes.fetch(event_name.to_sym, []).join(" ")
      Kernel.puts(recipes)
    rescue Dumbwaiter::Stack::NotFound, Dumbwaiter::Layer::NotFound => e
      raise Thor::Error.new(e.message)
    end

    desc "update_custom_recipes STACK LAYER EVENT RECIPE...", "Update custom recipes for an event"
    def update_custom_recipes(stack_name, layer_name, event_name, *recipes)
      stack = Stack.find(stack_name)
      layer = Layer.find(stack, layer_name)
      layer.update_custom_recipes(event_name.to_sym, recipes)
    rescue Dumbwaiter::Stack::NotFound, Dumbwaiter::Layer::NotFound => e
      raise Thor::Error.new(e.message)
    end

    desc "stacks", "List all the stacks"
    def stacks
      Stack.all.each { |stack| Kernel.puts("#{stack.name}: #{stack.apps.map(&:name).join(', ')}") }
    end

    desc "layers STACK", "List all the layers for a stack"
    def layers(stack_name)
      stack = Stack.find(stack_name)
      layer_names = stack.layers.map(&:shortname)
      Kernel.puts(layer_names.join(" "))
    rescue Dumbwaiter::Stack::NotFound => e
      raise Thor::Error.new(e.message)
    end
  end
end
