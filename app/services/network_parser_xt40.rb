class NetworkParserXt40
  # Mapeamento de MCC-MNC para operadoras brasileiras
  OPERATORS = {
    '724-00' => 'Nextel',
    '724-01' => 'Vivo',
    '724-02' => 'TIM',
    '724-03' => 'TIM',
    '724-04' => 'TIM',
    '724-05' => 'Claro',
    '724-06' => 'Vivo',
    '724-07' => 'CTBC',
    '724-08' => 'TIM',
    '724-10' => 'Vivo',
    '724-11' => 'Vivo',
    '724-15' => 'Sercomtel',
    '724-16' => 'Oi',
    '724-17' => 'Correios Celular',
    '724-18' => 'Datora',
    '724-23' => 'Vivo',
    '724-24' => 'Oi',
    '724-31' => 'Oi',
    '724-32' => 'CTBC',
    '724-33' => 'CTBC',
    '724-34' => 'CTBC',
    '724-37' => 'Unicel',
    '724-38' => 'Claro',
    '724-39' => 'Nextel'
  }.freeze

  # Mapeamento de tecnologias de rede
  NETWORK_MODES = {
    'GSM' => '2G',
    'EDGE' => '2G',
    'GPRS' => '2G',
    'WCDMA' => '3G',
    'UMTS' => '3G',
    'HSDPA' => '3G',
    'HSUPA' => '3G',
    'HSPA' => '3G',
    'LTE' => '4G',
    'NR' => '5G'
  }.freeze

  # Mapeamento de bandas LTE para frequências
  LTE_BANDS = {
    'EUTRAN-BAND1' => '2100 MHz',
    'EUTRAN-BAND2' => '1900 MHz',
    'EUTRAN-BAND3' => '1800 MHz',
    'EUTRAN-BAND4' => '1700/2100 MHz',
    'EUTRAN-BAND5' => '850 MHz',
    'EUTRAN-BAND7' => '2600 MHz',
    'EUTRAN-BAND8' => '900 MHz',
    'EUTRAN-BAND12' => '700 MHz',
    'EUTRAN-BAND13' => '700 MHz',
    'EUTRAN-BAND17' => '700 MHz',
    'EUTRAN-BAND20' => '800 MHz',
    'EUTRAN-BAND28' => '700 MHz',
    'EUTRAN-BAND38' => '2600 MHz',
    'EUTRAN-BAND40' => '2300 MHz',
    'EUTRAN-BAND41' => '2500 MHz'
  }.freeze

  def initialize(network_data)
    @network_data = network_data
  end

  def parse
    begin
      parsed_data = extract_network_info

      {
        network_mode: process_network_mode(parsed_data[:network_mode]),
        connection_status: parsed_data[:online] ? 'Online' : 'Offline',
        operator: process_operator(parsed_data[:mm]),
        operator_code: parsed_data[:mm],
        location_area_code: parsed_data[:lac],
        cell_id: parsed_data[:cell],
        signal_strength: process_signal_strength(parsed_data[:rxlev]),
        signal_quality: get_signal_quality(parsed_data[:rxlev]),
        frequency_band: process_frequency_band(parsed_data[:lband]),
        tracking_area_code: parsed_data[:tac],
        country_code: extract_country_code(parsed_data[:mm])
      }
    rescue StandardError => e
      error_message = "NetworkParserXt40.parse | Error: #{e.message}\nBacktrace:\n#{e.backtrace.first(5).join("\n")}"
      Rails.logger.error("#{error_message}\n")
      SaveLog.new('error_payload', error_message).save
      nil
    end
  end

  private

  def extract_network_info
    data = {}

    # NetworkMode
    data[:network_mode] = @network_data.match(/NetworkMode:(\w+)/i)&.[](1)

    # Status Online
    data[:online] = @network_data.include?('Online')

    # MM (MCC-MNC)
    data[:mm] = @network_data.match(/MM:(\d{3}-\d{2})/i)&.[](1)

    # LAC
    data[:lac] = @network_data.match(/LAC:(\d+)/i)&.[](1)

    # CELL
    data[:cell] = @network_data.match(/CELL:(\d+)/i)&.[](1)

    # RXLEV
    data[:rxlev] = @network_data.match(/RXLEV:(\d+)/i)&.[](1)&.to_i

    # Lband
    data[:lband] = @network_data.match(/Lband:([\w-]+)/i)&.[](1)

    # TAC
    data[:tac] = @network_data.match(/TAC:(\d+)/i)&.[](1)

    data
  end

  def process_network_mode(mode)
    return 'Desconhecido' unless mode

    NETWORK_MODES[mode.upcase] || mode
  end

  def process_operator(mm_code)
    return 'Operadora Desconhecida' unless mm_code

    OPERATORS[mm_code] || 'Operadora Desconhecida'
  end

  def process_signal_strength(rxlev)
    return 0 unless rxlev

    # Convertendo RXLEV (0-63) para porcentagem
    # RXLEV 0 = -110 dBm ou pior (0%)
    # RXLEV 63 = -48 dBm ou melhor (100%)
    percentage = ((rxlev.to_f / 63.0) * 100).round

    # Garantindo que não passe de 100%
    [percentage, 100].min
  end

  def get_signal_quality(rxlev)
    return 'Desconhecido' unless rxlev

    case rxlev
    when 0..20
      'Muito Ruim'
    when 21..40
      'Ruim'
    when 41..60
      'Boa'
    when 61..63
      'Excelente'
    else
      'Desconhecido'
    end
  end

  def process_frequency_band(lband)
    return 'Frequência Desconhecida' unless lband

    LTE_BANDS[lband.upcase] || lband
  end

  def extract_country_code(mm_code)
    return nil unless mm_code

    country_code = mm_code.split('-').first
    case country_code
    when '724'
      'Brasil'
    else
      'País Desconhecido'
    end
  end
end
