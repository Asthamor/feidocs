class Ckeditor::Picture < Ckeditor::Asset
  include Rails.application.routes.url_helpers

  def url_content
    rails_blob_url(storage_data)
  end

  def url_thumb
    rails_representation_url(storage_data.variant(resize: "118x100"))
  end

  class << self
    def default_url_options
      Rails.application.config.action_mailer.default_url_options
    end
  end
end