module AddedFunction
  def format_date(obj)
    obj.strftime("%d.%m.%Y")
  end
  
  def format_datetime(obj)
    obj.strftime("%d.%m.%Y %H:%M")
  end
  
  def random_password(size = 8)
    chars = (('a'..'z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0)
    (1..size).collect{|a| chars[rand(chars.size)] }.join
  end
end
