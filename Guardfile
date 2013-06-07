# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rspec, all_after_pass: false do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})          { 'spec' }
  watch('spec/spec_helper.rb')       { 'spec' }
  watch('Gemfile.lock')              { 'spec' }
end

