require 'spec_helper'

describe Shipr::Repo do
  subject(:repo) { described_class.create name: 'remind101/shipr' }

  describe '#clone_url' do
    subject { repo.clone_url }

    it { should eq 'git@github.com:remind101/shipr.git' }
  end
end
