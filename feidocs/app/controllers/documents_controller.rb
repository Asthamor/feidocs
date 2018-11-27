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

end