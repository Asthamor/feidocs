class DocumentsController < ApplicationController
  require 'htmltoword'
  require 'tempfile'

  #GET /documents
  def index
    #SELECT * ALL
    @documents = Document.where(professor_id: current_professor.id)
    #@activities = Activity.where(subject_id: params[:idSubject])
  end

  #GET /documents/:id
  def show
    #Encuentra un registro de documento por ID
    @document = Document.find(params[:id])
  end

  #GET documents/new
  def new
    @document = Document.new
  end

  def create
    @document = Document.new document_params
    @document.professor_id = current_professor.id
    fileDoc = Htmltoword::Document.create_and_save @document.description, 'C:\Users\Mari\Desktop\temporal\archivo.doc'
    @document.docfile.attach(io: File.open(fileDoc),
                             filename: "archivo.doc",
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

  def document_params
    params.require(:document).permit(:name, :docfile, :description)
  end


end