require Sufia::Engine.root.join('app/models/generic_file')
class GenericFile
  include CurationConcern::WithAccessRight
  include CurationConcern::Embargoable

  belongs_to :batch, property: :is_part_of, class_name: 'ActiveFedora::Base'

  validates :batch, presence: true
  validates :file, presence: true, on: :create

  attr_accessor :file, :version

  def filename
    content.label
  end

  def to_s
    title || label || "No Title"
  end

  def versions
    content.versions
  end

  def current_version_id
    content.latest_version.versionID
  end

  def human_readable_type
    self.class.to_s.demodulize.titleize
  end
end
