class DocumentsController < ApplicationController

  #GET /documents
  def index
    #SELECT * ALL
    @documents = Document.all
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
    #render plain: params[:image].inspect
    @document = Document.new document_params
    @document.professor_id = current_professor.id
    @document.save

    redirect_to @document
  end



  def document_params
    params.require(:document).permit(:name, :docfile)
  end

end