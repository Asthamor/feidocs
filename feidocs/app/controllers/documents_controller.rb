class DocumentsController < ApplicationController
  require 'htmltoword'
  require 'tempfile'
  require 'openssl'

  #GET /documents
  def index
    #SELECT * ALL
    @professors = Professor.all.where.not(id: current_professor)
    @document = Document.new
    @documents = Document.where(professor_id: current_professor.id)
    #@activities = Activity.where(subject_id: params[:idSubject])
  end

  def allshared
    #SELECT * ALL
    @professors = Professor.all.where.not(id: current_professor)
    @document = Document.new
    @documents = Document.where(collaborators: Collaborator.where(professor_id: current_professor.id))
  end

  #GET /documents/:id
  def show
    #Encuentra un registro de documento por ID
     @document = Document.find_by("id = ? AND professor_id = ?", params[:id], current_professor.id)
  end

  #GET /documents/shared/:id
  def shared
    #Encuentra un registro de documento por ID
     @documents = Document.where(collaborators: Collaborator.find_by("document_id = ? AND professor_id = ?", params[:id], current_professor.id))
     @document = @documents[0]
  end

  #GET documents/new
  def new
    @document = Document.new
  end

  def create
    @document = Document.new document_params
    @document.professor_id = current_professor.id
    fileDoc = Htmltoword::Document.create_and_save @document.description, 'C:\Users\zaret\Downloads\testruby\archivo.docx'
    @document.docfile.attach(io: File.open(fileDoc),
                             filename: "archivo.docx",
                             content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document')
    @document.save!
    fileDoc.close
    redirect_to @document
  end

  def upload
    @document = Document.new
  end

  def after_upload
    #render plain: params[:image].inspect
    @document = Document.new document_params
    @document.professor_id = current_professor.id
    @document.save
    redirect_to @document
  end

  def edit
    @document = Document.find params[:id]
  end

  def update
    @document = Document.find params[:id]
    @document.update documents_params
    redirect_to @document
  end

  def rename
    @document = Document.find params[:id]
  end

  def rename_upload
    @document = Document.find params[:documentid]
    @document.update document_newName
    redirect_to documents_path
  end

  def document_professor_upload
    @document = Document.find params[:documentid]
    @document.professors = params[:professors]
    @document.save
    redirect_to documents_path
  end

  def destroy
    #DELETE FROM documents
    @document = Document.find(params[:id])
    @document.destroy
    redirect_to documents_path
  end

  def convert
    require 'docx'
    docx_document = Document.find_by("id = ? AND professor_id = ?", params[:id], current_professor.id)
    docx = Docx::Document.open(ActiveStorage::Blob.service.send(:path_for, docx_document.filename.to_s))
    @document = Document.new
    @document.name = docx.name
    @document.description = docx.description
    pdf = WickedPdf.new.pdf_from_string(docx.to_html)
    @document.docfile.attach(io:File.open(pdf),
                             filename: docx.name,
                             content_type: "application/pdf")
    @document.professor_id = current_professor.id
    @document.save!
    redirect_to documents_path
  end

  def sign
    @document = Document.find(params[:format])
  end

  def after_sign
    @document = Document.find params[:documentid]
    @doc = Document.new documents_params_sign
    @doc.name =  @document.name
    @doc.professor_id= @document.professor_id
    @doc.description = @document.description

    digest = OpenSSL::Digest::SHA256.new
    #uploaded_io = params[:document][:private_key]
    #archivo1 = File.read(uploaded_io)
    #archivo = uploaded_io.read
    archivo = File.read('/home/maritello/Descargas/keys (1).pem')
    #archivo = File.read('/home/maritello/Descargas/privatekey(10).pem')
    key = OpenSSL::PKey::RSA.new archivo, "ilovemagic"

    #RECUPERA PDF Y OBTIENE SU PATH
    path = "/home/maritello/Escritorio/PROYECTO CERTIFICADOS/docsfirmados/docfile.pdf}"
    File.open(path, 'wb') do |file|
      file.write(@document.docfile.download)
    end
    document = File.open(path)

    #FIRMA Y GUARDA LA STRING EN UN ARCHIVO
    newsignature = key.sign digest, document.path
    path_hash = "/home/maritello/Escritorio/PROYECTO CERTIFICADOS/docsfirmados/hash"
    File.open(path_hash, "w:ASCII-8BIT") do |file|
      file.write(newsignature)
    end
    document_hash = File.open(path_hash)
    dochash = File.read(document_hash)

    #RECUPERA LLAVE PÚBLICA DE PROFESOR QUE SUBE DOCUMENTO
    signature = Signature.find_by(professor_id: current_professor.id)
    path_signature = "/home/maritello/Escritorio/PROYECTO CERTIFICADOS/docsfirmados/signature.pem"
    File.open(path_signature, 'wb') do |file|
      file.write(signature.public_key.download)
    end
    document_signature = File.open(path_signature)
    public = File.read(document_signature)

    #GENERA PDF CON PUBLICKEY Y DIGEST
    Prawn::Document.generate("/home/maritello/Escritorio/PROYECTO CERTIFICADOS/docsfirmados/certificado.pdf", :template => document) do
      font "Times-Roman"
      text "public key: + #{public.to_s}", :align => :center
      text "digest: + #{digest.to_s}", :align => :center
    end

    #COMBINA PDF RECIÉN CREADO Y EL ORIGINAL
    pdf = CombinePDF.new
    pdf << CombinePDF.load(document.path)
    pdf << CombinePDF.load("/home/maritello/Escritorio/PROYECTO CERTIFICADOS/docsfirmados/certificado.pdf")
    pdf.save '/home/maritello/Escritorio/PROYECTO CERTIFICADOS/docsfirmados/certificado.pdf'
    @doc.docfile.attach(io: File.open('/home/maritello/Escritorio/PROYECTO CERTIFICADOS/docsfirmados/certificado.pdf'),
                        filename: 'signed' + @doc.id.to_s + '.pdf',
                        content_type: 'application/pdf')
    @doc.firma.attach(io: File.open(path_hash),
                             filename: 'firma',
                             content_type: 'text/plain')
    @doc.save

    redirect_to @doc
  end

  def validate
    @document = Document.find(params[:format])
    digest = OpenSSL::Digest::SHA256.new

    path_hash = "/home/maritello/Escritorio/PROYECTO CERTIFICADOS/docsfirmados/signature.sha256"
    File.open(path_hash, 'wb') do |file|
      file.write(@document.firma.download)
    end
    document_hash = File.open(path_hash)
    dochash = File.read(document_hash)

    keydoc = Signature.find_by(professor_id: @document.professor_id)
    path_key = "/home/maritello/Escritorio/PROYECTO CERTIFICADOS/docsfirmados/publickey.pem"
    File.open(path_key, 'wb') do |file|
      file.write(keydoc.public_key.download)
    end
    document_key = File.open(path_key)
    publickey = File.read(document_key)

    path_doc = "/home/maritello/Escritorio/PROYECTO CERTIFICADOS/docsfirmados/doc.pdf"
    File.open(path_doc, 'wb') do |file|
      file.write(@document.docfile.download)
    end

    public_key = OpenSSL::PKey::RSA.new(publickey)

    if public_key.verify digest, dochash, path_doc
      puts 'Valid'
    else
      puts 'Invalid'
    end
  end

  private

  def document_params
    params.require(:document).permit(:name, :docfile, :description)
  end

  def document_newName
    params.require(:document).permit(:name)
  end

  def documents_params_sign
    params.require(:document).permit(:private_key, :pass)
  end

end