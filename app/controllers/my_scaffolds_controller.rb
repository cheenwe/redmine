class MyScaffoldsController < ApplicationController
  before_action :set_my_scaffold, only: [:show, :edit, :update, :destroy]

  # GET /my_scaffolds
  def index
    @my_scaffolds = MyScaffold.all
  end

  # GET /my_scaffolds/1
  def show
  end

  # GET /my_scaffolds/new
  def new
    @my_scaffold = MyScaffold.new
  end

  # GET /my_scaffolds/1/edit
  def edit
  end

  # POST /my_scaffolds
  def create
    @my_scaffold = MyScaffold.new(my_scaffold_params)

    if @my_scaffold.save
      redirect_to @my_scaffold, notice: 'My scaffold was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /my_scaffolds/1
  def update
    if @my_scaffold.update(my_scaffold_params)
      redirect_to @my_scaffold, notice: 'My scaffold was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /my_scaffolds/1
  def destroy
    @my_scaffold.destroy
    redirect_to my_scaffolds_url, notice: 'My scaffold was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_my_scaffold
      @my_scaffold = MyScaffold.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def my_scaffold_params
      params.require(:my_scaffold).permit(:name, :contact, :result)
    end
end
