load 'spec_helper.rb'
require 'yaml'

RSpec.describe '#handler_check' do

  it 'template.yml has valid handlers' do
    yaml = YAML.load_file('template.yml')
    yaml['Resources'].each do |k,v|
      if yaml['Resources'][k]['Type'] == 'AWS::Serverless::Function'
        match = false
        path, method = yaml['Resources'][k]['Properties']['Handler'].split(/\./)
        File.open("#{path}.rb").each do |line|
          match = true if line.match(/^\s*def\s#{method}/)
        end
        puts yaml['Resources'][k]['Properties']['Handler'] unless match
        expect(match).to be true
      end
    end
  end
end
