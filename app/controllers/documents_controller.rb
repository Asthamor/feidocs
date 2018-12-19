class DocumentsController < ApplicationController
  require 'htmltoword'
  require 'tempfile'

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
    require 'openssl'
    require 'origami'
    @document = Document.find params[:documentid]
    @doc = Document.new documents_params_sign
    @doc.name =  @document.name
    @doc.professor_id= @document.professor_id
    @doc.description = @document.description

    pass = params[:document][:pass]
    keys = params[:document][:private_key]

    digest = OpenSSL::Digest::SHA256.new
    #archivo = File.read('/home/maritello/Descargas/keys (1).pem')
    archivo = File.read(keys.tempfile.path)

    key = OpenSSL::PKey::RSA.new archivo, pass

    #RECUPERA PDF Y OBTIENE SU PATH
    #path = "/home/maritello/Escritorio/PROYECTO CERTIFICADOS/docsfirmados/docfile.pdf"
    path = Tempfile.new(['uploaded', '.pdf'], Rails.root.to_s + '/tmp/')
    File.open(path, 'wb') do |file|
      file.write(@document.docfile.download)
    end
    document = File.open(path)

    #FIRMA Y GUARDA LA STRING EN UN ARCHIVO
    newsignature = key.sign digest, document.path


    #GENERA PDF CON PUBLICKEY Y DIGEST
    pathtmp =  Tempfile.new(['public_digest', '.pdf'], Rails.root.to_s + '/tmp/')
    Prawn::Document.generate(pathtmp) do
      font "Times-Roman"
      text "public key: + #{key.public_key.to_s}", :align => :center
      text "digest: + #{digest.to_s}", :align => :center
    end

    #COMBINA PDF RECIÉN CREADO Y EL ORIGINAL
    pdf = CombinePDF.new
    pdf << CombinePDF.load(document.path)
    pdf << CombinePDF.load(pathtmp.path)
    final = Tempfile.new(['signed', '.pdf'], Rails.root.to_s + '/tmp/')
    pdf.save final.path
    #@doc.firma.attach(io: File.open(path_hash),
    #                         filename: 'firma',
    #                         content_type: 'text/plain')
    certificate = generate_certificate(key)
    pdf_certified = Origami::PDF.read final.path
    page = pdf_certified.get_page(1)
    rectangle = Origami::Annotation::Widget::Signature.new
    rectangle.Rect = Origami::Rectangle[:llx => 89.0, :lly => 386.0, :urx => 190.0, :ury => 353.0]
    #aqui se añade la signature al rectangle
    page.add_annotation(rectangle)
    pdf_certified.sign(certificate, key,
             :method => 'adbe.pkcs7.sha1',
             :annotation => rectangle,
             :location => "Mexico",
             :contact => current_professor.email,
             :reason => "Firma de enterado",
                       :issuer => current_professor.fullName,
    )

    finalcertified =  Tempfile.new(['certified', '.pdf'], Rails.root.to_s + '/tmp/')
    certificadopath = finalcertified.path
    #File.open(certificadopath, 'wb') do |file|
    #  file.write(pdf_certified)
    #end
    pdf_certified.save(certificadopath)
    #document = File.open(certificadopath)
    @doc.docfile.attach(io: File.open(certificadopath),
                        filename: 'signed' + @doc.id.to_s + '.pdf',
                        content_type: 'application/pdf')
    @doc.save!
    redirect_to @doc
  end

  def validate
    @document = Document.find(params[:format])

    path_doc = Tempfile.new(['validate', '.pdf'], Rails.root.to_s + '/tmp/')
    File.open(path_doc.path, 'wb') do |file|
      file.write(@document.docfile.download)
    end
    pdf_certified = Origami::PDF.read path_doc.path

    puts pdf_certified.signed?

  end

  private

  def generate_certificate(key)
    require 'openssl'
    professor = Professor.find(current_professor.id)
    name = OpenSSL::X509::Name.new [['CN',"#{professor.fullName}"], ['DC', 'UV']]
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = 0
    cert.not_before = Time.now
    cert.not_after = Time.now + 3600
    cert.public_key = key.public_key
    cert.subject = name
    cert.issuer = name
    cert
  end

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