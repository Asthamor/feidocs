class DocumentsController < ApplicationController
  before_action :authenticate_professor!
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
    begin
    require 'docx'
    #Encuentra un registro de documento por ID
    @document = Document.find_by("id = ? AND professor_id = ?", params[:id], current_professor.id)
    if @document.docfile.content_type == "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      doc_downloaded = Tempfile.new(['document', '.docx'], Rails.root.to_s + '/tmp/')
      File.open(doc_downloaded.path, 'wb') do |file|
        file.write(@document.docfile.download)
      end
      @pathdocument = doc_downloaded.path
    end
    rescue

      end
  end

  #GET /documents/shared/:id
  def shared
    begin
    #Encuentra un registro de documento por ID
     @documents = Document.where(collaborators: Collaborator.find_by("document_id = ? AND professor_id = ?", params[:id], current_professor.id))
     @document = @documents[0]
    rescue
    end
  end

  #GET documents/new
  def new
    @document = Document.new
  end

  def create
    begin
    @document = Document.new document_params
    @document.professor_id = current_professor.id
    dochtml =  Tempfile.new(['html', '.pdf'], Rails.root.to_s + '/tmp/')
    fileDoc = Htmltoword::Document.create_and_save @document.description, dochtml.path
    @document.docfile.attach(io: File.open(fileDoc),
                             filename: "archivo.docx",
                             content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document')
    @document.save!
    fileDoc.close
    redirect_to @document
    rescue
      render 'new'
      end
  end

  def upload
    @document = Document.new
  end

  def after_upload
    begin
    @document = Document.new document_params
    @document.description = "Description"

    if @document.docfile.content_type == "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    doc_uploaded = Tempfile.new(['document', '.docx'], Rails.root.to_s + '/tmp/')
    File.open(doc_uploaded.path, "w:ASCII-8BIT") do |file|
      file.write(@document.docfile.download)
    end
    docx = Docx::Document.open(doc_uploaded.path)
    @document.description = docx.to_html
    end

    @document.professor_id = current_professor.id
    @document.save!
    redirect_to @document
    rescue
      render 'upload'
    end
  end

  def edit
    @document = Document.find @document = Document.find_by("id = ? AND professor_id = ?", params[:id], current_professor.id)
  end

  def update
    begin
    @document = Document.find params[:id]
    @document.update documents_params
    redirect_to @document
    rescue
      render 'edit'
      end
  end

  def document_professor_upload
    begin
    @document = Document.find params[:documentid]
    @document.professors = params[:professors]
    @document.save!
    redirect_to documents_path
    rescue
    end
  end

  def destroy
    begin
    #DELETE FROM documents
    @document = Document.find(params[:id])
    @document.destroy!
    redirect_to documents_path
    rescue
      end
  end

  def convert
    require 'docx'
    docx_document = Document.find(params[:id])

    doc_downloaded = Tempfile.new(['document', '.docx'], Rails.root.to_s + '/tmp/')
    File.open(doc_downloaded.path, "wb") do |file|
      file.write(docx_document.docfile.download)
    end

    docx = Docx::Document.open(doc_downloaded.path)
    @document = Document.new
    @document.name = docx_document.name
    #@document.description = docx.to_html

    html_doc = Tempfile.new(['document', '.html'], Rails.root.to_s + '/tmp/')
    File.open(html_doc.path, "wb") do |file|
      file.write(docx_document.description)
    end

    pdf = WickedPdf.new.pdf_from_html_file(html_doc.path)

    pdf_file = Tempfile.new(['pdf', '.pdf'], Rails.root.to_s + '/tmp/')
    File.open(pdf_file.path, "wb") do |file|
      file.write(pdf)
    end
    @document.description = docx_document.description
    @document.docfile.attach(io:File.open(pdf_file.path),
                             filename: docx_document.name,
                             content_type: "application/pdf")
    @document.professor_id = current_professor.id
    @document.save!
    redirect_to @document
  end

  def sign
    @document = Document.find(params[:format])
  end

  def after_sign
    begin
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
    archivo = File.read(keys.tempfile.path)

    key = OpenSSL::PKey::RSA.new archivo, pass

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
    pdf_certified.save(certificadopath)
    @doc.docfile.attach(io: File.open(certificadopath),
                        filename: 'signed' + @doc.id.to_s + '.pdf',
                        content_type: 'application/pdf')
    @doc.save!
    redirect_to @doc
    rescue
      render 'sign'
    end
  end

  def validate
    begin
    @document = Document.find(params[:format])

    path_doc = Tempfile.new(['validate', '.pdf'], Rails.root.to_s + '/tmp/')
    File.open(path_doc.path, 'wb') do |file|
      file.write(@document.docfile.download)
    end
    pdf_certified = Origami::PDF.read path_doc.path

    puts pdf_certified.signed?
    rescue
    end
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