include ERB::Util
include ActiveSupport::CoreExtensions
include ActionView::Helpers::NumberHelper

class DateTime
 def to_time
   Time.mktime(year, mon, day, hour, min, sec)
 end
end

class Time
  def to_datetime
    DateTime.civil(year, mon, day, hour, min, sec)
  end
end

module HelpersPlugin
  def authorized?(permission)
    return @controller.authorized?(permission)
  end
  
  def multi_authorized?(permissions, cond = 'or')
    unless permissions.blank?
      if cond == 'or'
        permissions.each{|p| return true if @controller.authorized?(p)}
        return false
      else
        permissions.each{|p| return false unless @controller.authorized?(p)}
        return true
      end
    end
    return false
  end
  
  def generate_csv(it) #input is 2-dimensional array 1st dimension is row, 2nd column
    it.collect{|i| i.join(';')}.join("\n")
  end
  
  def full_domain(subdomain)
    return subdomain + '.' + SYSTEM_DOMAIN 
  end
  
  def hx(obj, max = 0)
    if (obj.to_s.size > 0)
      if max > 0 && obj.to_s.chars.size > max -2
        h(obj.to_s.chars[0..max-2] + '...')
      else
       h(obj.to_s)
      end
    else
      "---"
    end
  end
  
  def hb(obj)
    if (obj.to_s.size > 0)
      obj.to_s=='1' || obj==true ? 'yes':'no'
    else
      "-"
    end
  end
  
  def hmail(obj)
    if (obj.to_s.size > 0)
      mail_to(obj.to_s, obj.to_s)
    else
      "-"
    end
  end
  
  def hwww(obj)
    if (obj.to_s.size > 0)
      if obj.to_s.include?('http://')
        "<a target='_blank' href='#{obj.to_s}'>#{obj.to_s}</a>"
      else
        "<a target='_blank' href='http://#{obj.to_s}'>#{obj.to_s}</a>"
      end
    else
      "-"
    end
  end
  
  def hmoney(obj, currency_code='')
    return obj.nil? ? '-' : (number_to_currency(obj, :unit => '&euro;') + (currency_code.blank? ? '':(' '+currency_code)))
    rescue
      return '-'
  end
  
  def hlmoney(obj, currency_code='')
    return obj.nil? ? '-' : (number_to_currency(obj, :unit => '&euro;') + (currency_code.blank? ? '':(currency_code)))
    rescue
      return '-'
  end
  
  def hsmoney(obj)
    return obj.blank? ? '---------' : number_to_currency(obj, :unit => '&euro;', :precision => 0)
    rescue
      return '-'
  end
  
  def hdate(obj)
    return obj.nil? ? '-' : (obj.class == Time || obj.class == DateTime ? obj.to_s(:eu_date) : obj.to_s(:eu))
    rescue
      return '-'
  end
  
  def hdatetime(obj)
    return obj.nil? ? '-' : obj.to_s(:eu_datetime)
    rescue
      return '-'
  end
  
  def hxdate(obj)
    return obj.nil? ? '' : obj.to_s(:eu)
    rescue
      return '-'
  end
  
  def htime(obj)
    return obj.nil? ? '-' : obj.to_s(:eu)
    rescue
      return '-'
  end
  
  def huser(obj)
    return obj.nil? ? '-' : obj.full_name
    rescue
      return '-'
  end
  
  def hnil text
    return text.blank? ? '---' : text
  end
  
  def hblank text
    return text.blank? ? '---' : text
  end
  
  def hpercent(num)
    num = 0 if num.nil?
    number_to_percentage(num, {:precision => 1})
  end
    
  def date_field(object_name, property_name, options = {})
    tmp = ""
    tmp << text_field_tag(object_name+'_'+property_name, hxdate(eval("@#{object_name}.#{property_name}")), {:class => "datefield", :name => object_name+'['+property_name+']'}.merge(options)) << "&nbsp;\n"
    tmp << image_tag('/images/icons/silk/calendar.png', { :id => property_name + "_calendar", :style => 'vertical-align: middle; cursor: pointer; border: 1px solid red;', :title => 'Select date', :onmouseover => "this.style.background='red';", :onmouseout => "this.style.background=''" }) << "\n"
    tmp << "<script type=\"text/javascript\">Calendar.setup({inputField :\"" << object_name << "_" << property_name << "\", ifFormat:\"%d.%m.%Y\", button:\"" << property_name << "_calendar\"});</script>"
    return custom_error_wrapper(object_name, property_name.gsub('_localized',''), tmp)
  end
  
  def date_field_tag(name, name2, value = nil, options = {})
    tmp = ""
    tmp << text_field_tag(name+'_'+name2, value, {:class => "datefield", :name => name+'['+name2+']'}.merge(options)) << "&nbsp;\n"
    tmp << image_tag('/images/icons/silk/calendar.png', { :id => name2 + "_calendar", :style => 'vertical-align: middle; cursor: pointer; border: 1px solid red;', :title => 'Select date', :onmouseover => "this.style.background='red';", :onmouseout => "this.style.background=''" }) << "\n"
    tmp << "<script type=\"text/javascript\">Calendar.setup({inputField :\"" << name << "_" << name2 << "\", ifFormat:\"%d.%m.%Y\", button:\"" << name2 << "_calendar\"});</script>"
    return custom_error_wrapper(name, name2.gsub('_localized',''), tmp)
  end
  
  def datetime_field(object_name, property_name, options = {})
    tmp = ""
    tmp << text_field_tag(object_name+'_'+property_name, eval("@#{object_name}.#{property_name}"), {:class => "datetimefield", :name => object_name+'['+property_name+']'}.merge(options)) << "&nbsp;\n"
    tmp << image_tag('/images/icons/silk/calendar.png', { :id => property_name + "_calendar", :style => 'vertical-align: middle; cursor: pointer; border: 1px solid red;', :title => 'Select date', :onmouseover => "this.style.background='red';", :onmouseout => "this.style.background=''" }) << "\n"
    tmp << "<script type=\"text/javascript\">Calendar.setup({inputField :\"" << object_name << "_" << property_name << "\", ifFormat:\"%d.%m.%Y %H:%M\", button:\"" << property_name << "_calendar\",showsTime:\"true\"});</script>"
    return custom_error_wrapper(object_name, property_name.gsub('_localized',''), tmp)
  end
  
  def resizeable_text_area(object_name, property_name, options = {})
    return text_area(object_name, property_name, {'rows' => 1, 'onfocus' => 'this.rows = 10; return false;', 'onblur' => 'this.rows = 1; return false;' }.merge(options))
  end
   
  def format_price_words(price, currency_description, cent_description)
    part1 = price.to_s.split('.')[0]
    part2 = price.to_s.split('.')[1]
    part2 << '0' if !(part2.nil?) && part2.size == 1 
    
    text = format_number_words(part1.to_i) << ' '
    text << currency_description << ' '
    unless part2.nil? || part2.to_i == 0
      text << format_number_words(part2.to_i) << ' '
      text << cent_description
    end
    
    return text
  end

  def format_number_words(price)
       
    text = ""
    postfix = ''
    miliony = (price / 1000000).to_i
    unless miliony == 0
        postfix = ''
        stovky_milionu = (miliony / 100).to_i

        unless stovky_milionu == 0
            text += @@stovky[stovky_milionu]
            miliony -= stovky_milionu * 100
            postfix = 'miliónů'
        end
        desitky_milionu = (miliony / 10).to_i
        if desitky_milionu != 0 and desitky_milionu > 1
            text += @@desitky[desitky_milionu]
            miliony -= desitky_milionu * 10
            postfix = 'miliónů'
        end
        unless miliony == 0
            if ((miliony == 1) & (desitky_milionu < 1))||((miliony == 1) && (stovky_milionu < 1))
                text += 'jeden'    
            else
                text += @@jednotky[miliony]
            end
            if postfix.empty?
                case miliony
                when 1
                    postfix = 'milión'
                when 2..4
                    postfix = 'milióny'
                when 5..19
                    postfix = 'miliónů'
                end
            end
        end
        price -= (price / 1000000).to_i * 1000000
    end
   
    text += postfix

    tisice = (price / 1000).to_i
    unless tisice == 0
        postfix = ''
        stovky_tisice = (tisice / 100).to_i
        unless stovky_tisice == 0
            text += @@stovky[stovky_tisice]
            tisice -= stovky_tisice * 100
            postfix = 'tisíc'
        end
        desitky_tisice = (tisice / 10).to_i
        if desitky_tisice != 0 and desitky_tisice > 1
            text += @@desitky[desitky_tisice]
            tisice -= desitky_tisice * 10
            postfix = 'tisíc'
        end
        unless tisice == 0
            text += @@jednotky[tisice]
            if postfix.empty?
                case tisice
                when 1
                    postfix = 'tisíc'
                when 2..4
                    postfix = 'tisíce'
                when 5..19
                    postfix = 'tisíc'
                end
            end
        end
       
        price -= (price / 1000).to_i * 1000
        text += postfix
    end
   
   
    stovky = (price / 100).to_i
    unless stovky == 0
        text += @@stovky[stovky]
        price -= stovky * 100
    end
    desitky = (price / 10).to_i
    if price != 0 and desitky > 1
        text += @@desitky[desitky]
        price -= desitky * 10
    end
    #jednotky
    if price != 0 and  price > 1
        text += @@jednotky[price.to_i]
        price -= price * 10
    end
    save_pom = 0
    unless price == 0
        save_pom = price.to_i
        price -= price.floor
    end
#    if ((price >= 0.25)&&(price < 0.75))
#        price = 0.5.to_d
#        text += ' korun českých padesát haléřů'
#    elsif (price >= 0.75)    
#        text += 'korun českých'
#    elsif (price == 0)   
#        text += ' korun českých'
#    else
#        text += 'korun českých'
#    end             
    return text
   
  end 

  @@jednotky = {
    1 => 'jeden',
    2 => 'dva',
    3 => 'tři',
    4 => 'čtyři',
    5 => 'pět',
    6 => 'šest',
    7 => 'sedm',
    8 => 'osm',
    9 => 'devět',
    10 => 'deset',
    11 => 'jedenáct',
    12 => 'dvanáct',
    13 => 'třináct',
    14 => 'čtrnáct',
    15 => 'patnáct',
    16 => 'šestnáct',
    17 => 'sedmnáct',
    18 => 'osmnáct',
    19 => 'devatenáct',
  }

  @@desitky = {
    2 => 'dvacet',
    3 => 'třicet',
    4 => 'čtyřicet',
    5 => 'padesát',
    6 => 'šedesát',
    7 => 'sedmdesát',
    8 => 'osmdesát',
    9 => 'devadesát'
  }

  @@stovky = {
    1 => 'jednosto',
    2 => 'dvěstě',
    3 => 'třista',
    4 => 'čtyřista',
    5 => 'pětset',
    6 => 'šestset',
    7 => 'sedmset',
    8 => 'osmset',
    9 => 'devětset'
  }

  @@tisickovky = {
    1 => 'jeden',
    2 => 'dva',
    3 => 'tři',
    4 => 'čtyři',
    5 => 'pět',
    6 => 'šest',
    7 => 'sedm',
    8 => 'osm',
    9 => 'devět'
  }  
  
  BS        = "\\\\"
  BACKSLASH = "#{BS}textbackslash{}"
  HAT       = "#{BS}textasciicircum{}"
  TILDE     = "#{BS}textasciitilde{}"

  def latex_escape(s)
    s.to_s.
      gsub(/([{}])/, "#{BS}\\1").
      gsub(/\\/, BACKSLASH).
      gsub(/([_$&%#])/, "#{BS}\\1").
      gsub(/\^/, HAT).
      gsub(/~/, TILDE)
  end
  alias :l :latex_escape
  
  def hl(object, max = 0)
    if (o = object.to_s.chars).size > 0
      if max > 0 && o.size > max - 2
        l(o[0..max-2] + '...')
      else
       l(o)
      end
    else
      '-'
    end
  end
  
  def hdescript(desc, length)
    if desc.nil? or desc.blank?
      return '---'
    end
    return desc if desc.length <= length
    return desc[0..length] + '...'
  end

end