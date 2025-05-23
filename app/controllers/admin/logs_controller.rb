class Admin::LogsController < Admin::BaseController
  LOG_BASE_PATH = ENV["LOG_BASE_PATH"]
  ALLOWED_DIRECTORIES = %w[carros informacao].freeze
  LINES_TO_SHOW = 100

  def index
    @directories = ALLOWED_DIRECTORIES
  end

  def show_directory
    directory = params[:directory]
    full_path = File.join(LOG_BASE_PATH, directory)

    unless ALLOWED_DIRECTORIES.include?(directory) && Dir.exist?(full_path)
      redirect_to admin_logs_path, alert: "Diretório de log inválido ou não encontrado."
      return
    end

    @log_files = Dir.glob(File.join(full_path, "*.log"))
                    .map { |f| File.basename(f) }
                    .sort
    @directory_name = directory
  end

  def show_log
    @directory_name = params[:directory]
    @filename = params[:filename]
    @search_term = params[:search]&.strip

    unless ALLOWED_DIRECTORIES.include?(@directory_name) &&
           @filename.ends_with?(".log") &&
           !@filename.include?("..") # Prevenir path traversal
      redirect_to admin_directory_path(@directory_name), alert: "Nome de arquivo inválido."
      return
    end

    full_path = File.join(LOG_BASE_PATH, @directory_name, @filename)

    unless File.exist?(full_path)
      redirect_to admin_directory_path(@directory_name), alert: "Arquivo de log não encontrado."
      return
    end

    begin
      if @search_term.present?
        escaped_term = Shellwords.escape(@search_term)
        escaped_path = Shellwords.escape(full_path)
        command = "grep -i -n #{escaped_term} #{escaped_path}"
        @log_content = `#{command}`
        @is_search_result = true
      else
        escaped_path = Shellwords.escape(full_path)
        command = "tail -n #{LINES_TO_SHOW} #{escaped_path}"
        @log_content = `#{command}`
        @is_search_result = false
      end

      if @is_search_result && @log_content.blank?
        @log_content = "Nenhuma linha encontrada contendo '#{@search_term}'."
      end

    rescue => e
      @log_content = "Erro ao ler ou pesquisar o arquivo de log: #{e.message}"
      @is_search_result = @search_term.present?
    end
  end

  def clear_log
    directory_name = params[:directory]
    filename = params[:filename]

    unless ALLOWED_DIRECTORIES.include?(directory_name) &&
           filename.ends_with?(".log") &&
           !filename.include?("..")
      redirect_to admin_logs_path, alert: "Acesso inválido."
      return
    end

    full_path = File.join(LOG_BASE_PATH, directory_name, filename)

    unless File.exist?(full_path)
      redirect_to directory_admin_logs_path(directory_name), alert: "Arquivo de log não encontrado."
      return
    end

    begin
      # Limpa o conteúdo do arquivo (truncando para 0 bytes)
      File.truncate(full_path, 0)
      # Alternativa com shell (pode ser necessária se houver problemas de permissão com File.truncate):
      # escaped_path = Shellwords.escape(full_path)
      # system("> #{escaped_path}")

      redirect_to log_file_admin_logs_path(directory: directory_name, filename: filename),
                  notice: "Arquivo de log '#{filename}' limpo com sucesso."
    rescue => e
      redirect_to log_file_admin_logs_path(directory: directory_name, filename: filename),
                  alert: "Erro ao limpar o arquivo de log: #{e.message}"
    end
  end
end
