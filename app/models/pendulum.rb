require 'net/http'
require 'csv'

class WufooError < Exception; end

class Pendulum
  
  def self.parse
    data = Pendulum.load_from_web!
  end
  
  # fetches and loads currency data from xe.com into the currencies table
  def self.load_from_web!
    csv = Pendulum.request
    Pendulum.parse_csv(csv)
  end

  # loads currency data from an xe.com file into the currencies table
  def self.load_from_file!(file)
    csv = File.read(file)
    Pendulum.parse_csv(csv)
  end
  
  def self.request
    begin
      response = Net::HTTP.get_response(URI.parse("http://urbanwide.wufoo.com/export/report/otley-science-festival-pendulum-results.csv"))      
      # response = Net::HTTP.get_response(URI.parse("http://urbanwide.com/download/gravity-calc.csv"))      
    rescue Exception => e
      raise WufooError, "Unable to connect to wufoo api: #{e.message}"
    end
    raise WufooError, "wufoo returned response code: #{response.code}" unless response.code == "200"
    return response.body
  end

  def self.calculate(n,t,l)
    (4 * (Math::PI ** 2) * l) / ((t / n) ** 2 )
  end

  def self.parse_csv(body)
    out = []
    csv = CSV::Reader.parse(body)
    count = 0
    
    csv.each_with_index do |row, x|
      unless x == 0
        n = BigDecimal(row[1])
        t = BigDecimal(row[2])
        l = BigDecimal(row[3])

        g = Pendulum.calculate(n,t,l)
	if g >= 5.0 and g < 15.0
       	  out[count] = {:gravity => g, :time => row[4] }
          total = 0
          out.each do |result|
            total += result[:gravity]
          end

          out[count][:average_gravity] = total / out.length
          count += 1
	end
      end

    end
    out
  end
  
end
