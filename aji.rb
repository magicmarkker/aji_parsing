class Aji

  attr_reader :page_x, :page_y

  def initialize(options =  {})
    @page_x = (options[:page_x].nil?) ? 612 : options[:page_x].to_i
    @page_y = (options[:page_y].nil?) ? 792 : options[:page_y].to_i
  end

  def aji_to_xml(options = {})
    raise Exception,'Missing required aji values for conversion' if(options[:x]||options[:y]||options[:w]||options[:h]) == nil
    {   
  :x1 =>  ax_to_x(options[:x]), 
  :y1 =>  ay_to_y(options[:y] + options[:h]), 
  :x2 =>  ax_to_x(options[:x] + options[:w]), 
  :y2 =>  ay_to_y(options[:y]) 
    }
  end

  def xml_to_aji(options = {})
    raise Exception,'Missing required xml values for conversion' if(options[:x1]||options[:y1]||options[:x2]||options[:y2]) == nil
    {  
  :x => x_to_ax(options[:x1]),
  :y => y_to_ay(options[:y2]),
  :w => x_to_ax(options[:x2]-options[:x1]),
  :h => y_to_ay(options[:y1]-options[:y2])
    }    
  end

  def x_to_ax(x)
    (x / self.page_x).to_f
  end

  def y_to_ay(y)
    ((self.page_y - y) / page_y).to_f
  end

  def ax_to_x(ax)
    (ax * self.page_x).to_f
  end

  def ay_to_y(ay)
    (self.page_y - (ay * self.page_y)).to_f
  end

  def slope(x1, y1, x2, y2)
    (y2 -y1) / (x2 - x1)
  end

end

@an = Aji.new({ :page_x => 612, :page_y => 792})
@x1 = @an.ax_to_x(0.197581)
@y1 = @an.ay_to_y(0.516355)
@x2 = @an.ax_to_x(0.201109)
@y2 = @an.ay_to_y(0.514019)
puts @x1
puts @y1
puts @x2
puts @y2
puts "SLOPE"
puts @an.slope(@x1, @y1, @x2, @y2)
puts "\n\n"
@x1 = @an.ax_to_x(0.222782)
@y1 = @an.ay_to_y(0.502726)
@x2 = @an.ax_to_x(0.278226)
@y2 = @an.ay_to_y(0.473520)
puts @x1
puts @y1
puts @x2
puts @y2
puts "SLOPE"
puts @an.slope(@x1, @y1, @x2, @y2)