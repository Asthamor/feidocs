module Ckeditor
  module ActiveStorage
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods
      def self.extended(base)
        base.class_eval do
          before_save :apply_data
        end
      end
    end

    module InstanceMethods
      protected

      def file
        @file ||= storage_data
      end

      def blob
        @blob ||= ::ActiveStorage::Blob.find(file.attachment.blob_id)
      end

      def apply_data
        if data.is_a?(Ckeditor::Http::QqFile)
          storage_data.attach(io: data, filename: data.original_filename)
        else
          storage_data.attach(data)
        end
        self.data_file_name = blob.filename
        self.data_content_type = blob.content_type
        self.data_file_size = blob.byte_size
      end
    end
  end
end