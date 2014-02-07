# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rspec, all_after_pass: false do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})          { 'spec' }
  watch('spec/spec_helper.rb')       { 'spec' }
  watch('Gemfile.lock')              { 'spec' }
end


guard 'cucumber' do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$})          { 'features' }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
end
