class Admin::CommandsController < Admin::BaseController
  before_action :set_command, only: %i[ show edit update destroy ]

  def index
    @search = Command.all.ransack(params[:q])

    respond_to do |format|
      format.html { @pagy, @commands = pagy(@search.result) }
      format.csv  { render csv: @search.result }
    end
  end

  def show
  end

  def new
    @command = Command.new
  end

  def edit
  end

  def create
    @command = Command.new(command_params)

    if @command.save
      redirect_to [:admin, @command], notice: "Command was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @command.update(command_params)
      redirect_to [:admin, @command], notice: "Command was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @command.destroy!
    redirect_to admin_commands_url, notice: "Command was successfully destroyed."
  end

  private
    def set_command
      @command = Command.find(params[:id])
    end

    def command_params
      params.require(:command).permit(:id, :type_device, :name, :command, :description, :created_at, :updated_at)
    end
end
