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

    uploaded_io = params[:document][:private_key]
    #archivo1 = File.read(uploaded_io)
    #archivo = uploaded_io.read
    archivo = File.read('/home/maritello/Escritorio/privatekey(1).pem')
    #archivo = File.read('/home/maritello/Descargas/privatekey(10).pem')


    key = OpenSSL::PKey::RSA.new archivo

    newsignature = key.sign digest, @document.docfile
    hash =  File.new('\home\maritello\Documentos\git\feidocs\feidocs\tmp\hash' + @document.id + '.sha256' , "w+")
    open hash.path, 'w' do |io| io.write newsignature end
    hashdoc = DocumentHash.new
    hashdoc.hash.attach(io: File.open(hash),
                        filename: 'hash.sha256',
                        content_type: 'text/sha256')
    #filename = "#{Prawn::DATADIR}/pdfs/multipage_template.pdf"
    signature = Signature.find_by(professor_id: current_professor.id)

    Prawn::Document.generate("certificado.pdf", :template => url_for(@document.docfile)) do
      font "Times-Roman"
      text "public key: + #{signature.public_key.to_s}", :align => :center
      text "digest: + #{digest.to_s}", :align => :center
    end

    pdf = CombinePDF.new
    pdf << CombinePDF.load(archivo)
    pdf << CombinePDF.load(url_for(@document.docfile))
    pdf.save '\home\maritello\Documentos\git\feidocs\feidocs\tmp\documentoCertificado.pdf'
    @doc.docfile.attach(io: File.open(pdf),
                        filename: 'signed' + @doc.id + '.pdf',
                        content_type: 'application/pdf')
    @doc.save
    hashdoc.document_id = @doc.id

    hashdoc.save
    redirect_to @doc
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