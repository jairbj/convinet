function processaContribuicao() {      

    $cartao_numero = $('input#cartao_numero').val();
    $cartao_cvv = $('input#cartao_cvv').val();
    $cartao_mes = $('input#cartao_mes').val();
    $cartao_ano = $('input#cartao_ano').val();
    $cartao_nome = $('input#cartao_nome').val();

    if (!$cartao_numero || naoNumerico($cartao_numero) || $cartao_numero.length != 16) {
      alert("Número do cartão inválido");
      return false;
    }
    if (!$cartao_cvv || naoNumerico($cartao_cvv) || $cartao_cvv.length < 3 ||  $cartao_cvv.length > 4) {
      alert("Código de segurança do cartão inválido");
      return false;
    }
    if (!$cartao_mes || naoNumerico($cartao_mes) || $cartao_mes.length != 2) {
      alert("Mês de validade inválido");
      return false;
    }
    if (!$cartao_ano || naoNumerico($cartao_ano) || $cartao_ano.length != 2) {
      alert("Ano de validade inválido");
      return false;
    }
    if (!$cartao_nome) {
      alert("Nome como consta no cartão é obrigatório");
      return false; 
    }

    $('input#contribuicao_nome_cartao').val($cartao_nome);

    $session = $('input#contribuicao_session').val();

    desabilitaBotao();
    PagSeguroDirectPayment.setSessionId($session);  

    PagSeguroDirectPayment.onSenderHashReady(function(response){
      if(response.status == 'error') {
          alert('Erro na comunicação com o PagSeguro, por favor tente novamente. COD: #01');
          console.log(response.message);
          return false;
          habilitaBotao();
      } else {                
        $('input#contribuicao_hash_cliente').val(response.senderHash);        
        geraTokenCartao($cartao_numero, $cartao_cvv, $cartao_mes, $cartao_ano);
      }
    });
}  


function desabilitaBotao() {
  $('button#processar').prop('disabled', true);  
}

function habilitaBotao() {
  $('button#processar').prop('disabled', false);
}


function geraTokenCartao($numero, $cvv, $mes, $ano) {  
  var param = {
    cardNumber: $numero,    
    cvv: $cvv,
    expirationMonth: $mes,
    expirationYear: "20" + $ano,
    success: function(response) {
      //token gerado, esse deve ser usado na chamada da API do Checkout Transparente
      $('input#contribuicao_token_cartao').val(response.card.token);      
      $('form#new_contribuicao').submit();      
    },
    error: function(response) {      
      console.log(response);
      habilitaBotao();      
      if (response.error){                
        $error = Object.keys(response.errors)[0]
        switch ($error) {
          case "10000":
            alert("Número do cartão inválido");
            return false;
            break;
          case "30400":
            alert("Dados do cartão inválidos");
            return false;
            break;
          case "10006":
            alert("CVV do cartão com tamanho inválido");
            return false;
            break;          
        }
      }
      alert('Erro na comunicação com o PagSeguro, por favor tente novamente. COD: #02');            
      return false;
    },
    complete: function(response) {
        //tratamento comum para todas chamadas
    }
  }
  
  PagSeguroDirectPayment.createCardToken(param);  
}



function naoNumerico(value) {
    var n = Number(value);
    return n !== n;
};