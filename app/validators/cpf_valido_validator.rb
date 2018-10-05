class CpfValidoValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    unless CPF.valid?(value)
      object.errors[attribute] << (options[:message] || 'é inválido inválido')
    end
  end
end
