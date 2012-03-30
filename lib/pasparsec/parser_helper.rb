module PasParsec::ParserHelper
  
  extend self

  def try_convert_into_pasparser! obj
    if obj.respond_to? :to_pasparser
      obj.to_pasparser
    else
      raise TypeError, "Can't convert #{obj.class} into PasParser"
    end
  end
end