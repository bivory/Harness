#! /usr/bin/env ruby -w
require 'date'

class MyDate
  def initialize (m, d, y)
    @dt = DateTime.new(y, m, d)
  end
  
  def leap_year?
    @dt.leap?
  end
  
  def day_of_week
    d = @dt.cwday
    case
    when d == 1
      "Monday"
    when d == 2
      "Tuesday"
    when d == 3
      "Wednesday"
    when d == 4 
      "Thursday"
    when d == 5
      "Friday"
    when d == 6
      "Saturday"
    else
      "Sunday"
    end
  end
  
  def week_of_year
    @dt.cweek
  end
  
  def day_of_year
    @dt.yday
  end
  
  def julian
    @dt.jd
  end
end
md = MyDate.new ARGV[0].to_i, ARGV[1].to_i, ARGV[2].to_i
puts "Day of week: " + md.day_of_week
puts "Week of year: " + md.week_of_year.to_s
puts "Day of year: " + md.day_of_year.to_s
puts "Julian date: " + md.julian.to_s 