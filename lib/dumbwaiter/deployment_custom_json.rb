require "hashie"
require "json"

class Dumbwaiter::DeploymentCustomJson
  def self.from_json(json_string)
    new(JSON.parse(json_string))
  end

  def self.create(name, ref)
    {deploy: {name => {scm: {revision: ref}}}}
  end

  def initialize(params)
    @params = params
  end

  def params
    Hashie::Mash.new(@params)
  end

  def app_name
    params.deploy.keys.first if params.deploy?
  end

  def revision
    params.deploy[app_name].scm.revision unless app_name.nil?
  end
end
