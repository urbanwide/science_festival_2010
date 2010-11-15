require 'net/http'
require 'csv'

class WufooError < Exception; end

class Slide
  
  def self.question(number)
    data = self.load_from_web!
    # Slide.new(:question => "ages 4 to 8", :data => {"15" => 3, "16" => 4, "17" => 4, "18" => 5})
  
    Slide.new(data[number.to_i])
  end

  def initialize args = {}
    @question = args[:question]
    @data = args[:data]
    @colour = args[:colour]
    @count = args[:count]
  end

  def question; @question; end
  def data; @data; end
  def colour; @colour; end
  def count; @count; end

  # fetches and loads currency data from xe.com into the currencies table
  def self.load_from_web!
    csv = Slide.request
    Slide.parse_csv(csv)
  end

  # loads currency data from an xe.com file into the currencies table
  def self.load_from_file!(file)
    csv = File.read(file)
    Slide.parse_csv(csv)
  end
  
  def self.request
    begin
      url = "http://urbanwide.wufoo.com/export/report/manager/is-otley-average.csv"
      # url = "http://urbanwide.wufoo.com/export/report/manager/toast-dropping-experiment.csv"
      response = Net::HTTP.get_response(URI.parse(url))
    rescue Exception => e
      raise WufooError, "Unable to connect to wufoo api: #{e.message}"
    end
    raise WufooError, "wufoo returned response code: #{response.code}" unless response.code == "200"
    return response.body
  end
  
  def chart_url
    chart = GoogleChart.new
    chart.type = :bar_vertical_stacked
    chart.data = self.data.sort.collect{|a| a[1]}
    chart.labels = self.data.keys.sort
    chart.colors = self.colour.sort.collect{|a| a[1]}.join("|")
    chart.height = 400
    chart.width = 700
    max = self.data.values.max
    # library doesn't support the following so hack them in!
    chart.to_url + "&chds=0,#{max}&chxr=0,0,#{max}&chxt=y&chbh=a&chxl=0:|0|#{max}"
  end

  def self.parse_csv(body)
    out = {} 
    csv = CSV::Reader.parse(body)
    
    underweight = "FDD017" # yellow
    normal = "4AA02C" #green
    overweight = "F88017" #orange
    obese = "C11B17" #red

    csv.each_with_index do |row, i|
      if i == 0 # first row, initialise
        out[1] = {:question => "Ages 4 to 8", :count => 0, :data => {}, :colour => {}}
        out[2] = {:question => "Ages 9 to 12", :count => 0, :data => {}, :colour => {}}
        out[3] = {:question => "Ages 13 to 16", :count => 0, :data => {}, :colour => {}}
        out[4] = {:question => "Ages 17 and Up", :count => 0, :data => {}, :colour => {}}
      else
        # pp row
        height = row[1].to_f
        weight = row[2].to_f
        age = row[3].to_i

        # bmi =  (weight / (height * height))
        bmi = (weight / (height * height)).round

        slide = 4 # default
        if age >= 4 && age < 9
          slide = 1
        elsif age >= 9 && age < 13
          slide = 2
        elsif age >= 13 && age < 17
          slide = 3
        else
          slide = 4
        end

        if bmi >= 10 && bmi <= 40 
          puts "AGE: #{age}, BMI: #{bmi}"
          out[slide][:data][bmi] ||= 0
          out[slide][:data][bmi] += 1
          out[slide][:count] += 1
        end
      end
    end

    (14..20).each do |no|
      out[1][:data][no] ||= 0
    end
    (14..25).each do |no|
      out[2][:data][no] ||= 0
    end
    (16..28).each do |no|
      out[3][:data][no] ||= 0
    end
    (18..30).each do |no|
      out[4][:data][no] ||= 0
    end

    # fill in missing nos
    (1..4).each do |slide|
      (out[slide][:data].min[0].to_i..out[slide][:data].max[0].to_i).each do |no|
        out[slide][:data][no] ||= 0
      end
    end

    # sort out the colours for the data we have
    cut = { 1 => {:low => 14, :mid => 18, :high => 20},
            2 => {:low => 14, :mid => 22, :high => 25},
            3 => {:low => 16, :mid => 24, :high => 28},
            4 => {:low => 18, :mid => 25, :high => 30}
    }

    cut.each do |slide, r|    
      out[slide][:data].each_key do |no|
        if no <= r[:low]
          out[slide][:colour][no] = underweight
        elsif no > r[:low] && no <= r[:mid]
          out[slide][:colour][no] = normal
        elsif no > r[:mid] && no <= r[:high]
          out[slide][:colour][no] = overweight
        elsif no > r[:high]
          out[slide][:colour][no] = obese
        end
      end
    end

    out
  end
  
end
