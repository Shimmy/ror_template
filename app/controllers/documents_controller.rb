class DocumentsController < ApplicationController
  before_action :set_document, only: %i[ show edit update destroy ]

  # GET /documents
  def index
    @documents = Document.all
    respond_to do |format|
      format.html
      format.json { render json: DocumentDatatable.new(params) }
    end
  end

  # GET /documents/1
  def show
  end

  # GET /documents/new
  def new
    @document = Document.new
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents
  def create
    @document = Document.new(document_params)

    if @document.save
      redirect_to @document, notice: "Document was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /documents/1
  def update
    if @document.update(document_params)
      redirect_to @document, notice: "Document was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /documents/1
  def destroy
    @document.destroy!
    redirect_to documents_path, notice: "Document was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def document_params
      params.expect(document: [ :name, :description, :user_id ])
    end
end
