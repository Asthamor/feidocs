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
    fileDoc = Htmltoword::Document.create_and_save @document.description, ''
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

  private

  def document_params
    params.require(:document).permit(:name, :docfile, :description)
  end

  def document_newName
    params.require(:document).permit(:name)
  end

end