require 'spec_helper'

describe CurationConcern::SeniorThesisActor do
  let(:pid) { CurationConcern.mint_a_pid }
  let(:user) { FactoryGirl.create(:user) }
  let(:curation_concern) { SeniorThesis.new(pid: pid)}
  let(:thesis_file_path) { __FILE__ }
  let(:thesis_file) { Rack::Test::UploadedFile.new(thesis_file_path, 'text/plain', false)}
  let(:assigned_doi) { 'abc-123' }
  let(:mock_doi_minter) { lambda {|pid|
      object = ActiveFedora::Base.find(pid, cast: true)
      object.identifier = assigned_doi
      object.save
      true
    }
  }

  subject {
    CurationConcern.actor(curation_concern, user, attributes)
  }

  before(:each) {
    subject.doi_minter = mock_doi_minter
  }

  describe '#create' do
    let(:attributes) {
      FactoryGirl.attributes_for(:senior_thesis).tap {|a|
        a[:thesis_file] = thesis_file
        a[:visibility] = 'psu'
        a[:assign_doi] = '1'
      }
    }
    describe 'valid attributes' do
      before(:each) do
        subject.create!
      end
      it do
        expect(curation_concern).to be_persisted
        curation_concern.date_uploaded.should == Date.today
        curation_concern.date_modified.should == Date.today
        curation_concern.depositor.should == user.user_key
        curation_concern.creator.should == user.name

        new_curation_concern = curation_concern.class.find(curation_concern.pid)

        new_curation_concern.generic_files.count.should == 1
        # Sanity test to make sure the file we uploaded is stored and has same permission as parent.
        senior_thesis_file = new_curation_concern.generic_files.first
        senior_thesis_file.content.content.should == thesis_file.read
        senior_thesis_file.filename.should == File.basename(thesis_file_path)
        senior_thesis_file.to_s.should == 'Senior Thesis'

        expect(new_curation_concern.to_solr['read_access_group_t']).to eq(['registered'])
        expect(senior_thesis_file.to_solr['read_access_group_t']).to eq(['registered'])
        expect(new_curation_concern.identifier).to eq(assigned_doi)
      end
    end
  end

  describe '#update' do
    before(:each) {
      subject.doi_minter = mock_doi_minter
    }

    let(:attributes) {
      FactoryGirl.attributes_for(:senior_thesis).tap {|a|
        a[:visibility] = 'open'
        a[:assign_doi] = '1'
      }
    }
    describe 'valid attributes' do
      before(:all) do
        curation_concern.apply_depositor_metadata(user.user_key)
      end
      it do
        subject.update!
        expect(curation_concern.identifier).to be_blank
        expect(curation_concern).to be_persisted
        curation_concern.permissions.select{|r| r[:type] == 'group' && r[:name]=='public'}.count == 1
        new_curation_concern = curation_concern.class.find(curation_concern.pid)
        expect(new_curation_concern.identifier).to eq(assigned_doi)
      end

    end
  end

end
