require 'spec_helper'

describe CharacterizeJob do

  # I'm not entirely certain where I want to put this. Given that it is
  # leaning on an actor, I'd like to put it there. But actors are going to
  # push to a queue, so it is the worker that should choke.
  describe '#run' do
    let(:user) { FactoryGirl.create(:user) }
    let(:senior_thesis) {
      FactoryGirl.create_curation_concern(:senior_thesis, user)
    }
    it 'deletes the generic file when I upload a virus' do
      EnvironmentOverride.with_anti_virus_scanner(false) do
        expect {
          FactoryGirl.create_generic_file(senior_thesis, user)
        }.to raise_error(AntiVirusScanner::VirusDetected)
        expect(senior_thesis.generic_files.count).to eq(0)
      end
    end
  end
end
