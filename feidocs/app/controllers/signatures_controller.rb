class SignaturesController < ApplicationController
require 'openssl'
require 'tempfile'

  def new
    @signature = Signature.find_by(professor_id: current_professor.id)
    if !@signature
      @signature = Signature.new
      @minimum_password_length = 6
      end
  end

  def create
    @signature = Signature.new signature_params
    if @signature.password == @signature.confirmation
        key = OpenSSL::PKey::RSA.new 2048
        public = Tempfile.new(['key', '.pem'])
        #private = Tempfile.new(['key', '.pem'])
        open public.path, 'w' do |io| io.write key.public_key.to_pem end
        #open private.path, 'w' do |io| io.write key.to_pem end
        #open 'private_key.pem', 'w' do |io| io.write key.to_pem end
        #open 'public_key.pem', 'w' do |io| io.write key.public_key.to_pem end

        cipher = OpenSSL::Cipher.new 'AES-128-CBC'
        pass_phrase = @signature.password
        key_secure = key.export cipher, pass_phrase

        #open 'private.secure.pem', 'w' do |io| io.write key_secure end

        @signature.public_key.attach(io: File.open(public),
                                     filename: "key-" + current_professor.id.to_s + ".pem",
                                     content_type: 'application/x-pem-file')
        @signature.professor_id = current_professor.id

        #file.read
        #file.close
        #file.unlink
        #@signature.private_key = @privates.path
        @signature.save

        @privates = Tempfile.new(['key', '.secure.pem'])
        open @privates.path, 'w' do |io| io.write key_secure end

        redirect_to download_signature_path(path: @privates.path)
    else
      redirect_to new_signature_path
    end
  end

def download
  send_file(
      params[:path],
      filename: "privatekey.pem",
      type: "application/x-pem-file"
  )
  File.delete(params[:path])
end

  private

  def signature_params
      params.require(:signature).permit(:password, :confirmation)
  end

end
