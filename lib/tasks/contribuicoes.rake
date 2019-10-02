namespace :contribuicoes do
  desc 'Sincroniza contribuições do PagSeguro com o banco de dados.'
  task :sincroniza, [:parcial] => :environment do | task,args |    
    if args[:parcial] and args[:parcial] == 'true'
      inicio = Time.now.in_time_zone('Brasilia') - 30.minutes
    else
      inicio = Time.now.in_time_zone('Brasilia') - 1.days
    end

    credentials = PagSeguro::AccountCredentials.new(PagSeguro.email, PagSeguro.token)

    options = {
      credentials: credentials,
      starts_at: inicio,
      ends_at: Time.now.in_time_zone('Brasilia')
    }

    begin
      report = PagSeguro::Subscription.search_by_date_interval(options)
    rescue
      return false
    end

    unless report.valid?
      puts 'PAGSEGURO: Erro recuperar contribuicao'
      puts report.errors.join("\n")
      puts options
      return false
    end

    contribuicoes_recuperadas = 0

    while report.next_page?
      report.next_page!
      report.subscriptions.each do |s|

        next unless s.name.start_with? Rails.configuration.convinet['prefixo_plano_pagseguro']

        next if (contribuicao = Contribuicao.find_by(codigo: s.code))

        next unless (plano = Plano.find_by(nome: s.name))

        # Pega os dados da contribuição
        begin
          s_data = PagSeguro::Subscription.find_by_code(s.code, credentials: credentials)
        rescue
          next
        end

        if PagSeguro.environment == :sandbox
          usuario = Usuario.find_by(id: s_data.sender.email.scan(/user(.*?)\@.*/)[0][0])              
        else
          usuario = Usuario.find_by(email: s_data.sender.email)
        end

        next unless usuario

        c = Contribuicao.new
        c.usuario = usuario
        c.codigo = s.code
        c.atualizar_status(s.status)
        c.plano = plano
        contribuicoes_recuperadas += 1 if c.save

        unless usuario.telefone
          t = Telefone.new
          t.usuario = usuario
          t.ddd = s_data.sender.phone.area_code
          t.numero = s_data.sender.phone.number
          t.save
        end

        unless usuario.endereco
          e = Endereco.new
          e.usuario = usuario
          e.rua = s_data.sender.address.street
          e.numero = s_data.sender.address.number
          e.complemento = s_data.sender.address.complement
          e.bairro = s_data.sender.address.district
          e.cidade = s_data.sender.address.city
          e.estado = s_data.sender.address.state
          e.cep = s_data.sender.address.postal_code
          e.save
        end

        if (pre = usuario.pre_cadastros.ativo.find_by(plano: plano.id))
          # TODO: Corrigir essa lógica do valor no model
          pre.valor = pre.valor.to_i
          pre.efetuado!
        end
      end
    end

    puts "PAGSEGURO: Contribuições recuperadas: #{contribuicoes_recuperadas}"
  end

  desc 'Atualiza status das contribuicoes que estão no banco de dados.'
  task atualiza_status: :environment do 
    credentials = PagSeguro::AccountCredentials.new(PagSeguro.email, PagSeguro.token)

    status_atualizados = 0

    Contribuicao.all.each do |c|

      begin
        s = PagSeguro::Subscription.find_by_code(c.codigo, credentials: credentials)
      rescue
        next
      end

      if s.errors.any?      
        puts 'PAGSEGURO -> ERRO AO BUSCA CONTRIBUIÇÃO'
        puts s.errors.join('\n')      
        next
      end

      status_anterior = c.status
      c.atualizar_status(s.status)
      c.save
      status_atualizados += 1 if status_anterior != c.status
    end

    puts "PAGSEGURO: Status atualizados: #{status_atualizados}"
  end

end
