class SignaturesController < ApplicationController
  before_action :authenticate_professor!
require 'openssl'
require 'tempfile'

  def new
    begin
    @signature = Signature.find_by(professor_id: current_professor.id)
    if !@signature
      @signature = Signature.new
      @minimum_password_length = 6
    end
    rescue
      end
  end

  def create
    begin
    @signature = Signature.new signature_params
    if @signature.password == @signature.confirmation
        key = OpenSSL::PKey::RSA.new 4096
        cipher = OpenSSL::Cipher.new 'AES-128-CBC'
        pass_phrase = @signature.password
        key_secure = key.export cipher, pass_phrase
        #Guarda llave pública
        public = Tempfile.new(['publickey', '.pem'])
        open public.path, 'w' do |io| io.write key.public_key end

        @signature.public_key.attach(io: File.open(public),
                                     filename: "publickey-" + current_professor.id.to_s + ".pem",
                                     content_type: 'application/x-pem-file')
        @signature.professor_id = current_professor.id
        @signature.save
        #Guarda y descarga ambas llaves
        bothkeys = Tempfile.new(['privatekey', '.pem'])
        open bothkeys.path, 'w' do |io| io.write key_secure end

        redirect_to download_signature_path(path: bothkeys.path)
    else
      flash[:notice] = "La contraseña y la confirmación no coinciden."
      redirect_to new_signature_path
    end
    rescue
      end
  end

def download
  puts params[:path]

  send_file(
      params[:path],
      filename: "keys.pem",
      type: "application/x-pem-file"
  )
end

  private

  def signature_params
      params.require(:signature).permit(:password, :confirmation)
  end

end
