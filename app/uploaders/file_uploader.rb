# encoding: utf-8

class FileUploader < CarrierWave::Uploader::Base
  storage :file
  
  def store_dir
    "#{::Rails.root.to_s}/public/uploaded_files/"
  end

  def extension_white_list
    %w(txt xls ods csv)
  end

  def move_to_store
    true
  end

end
