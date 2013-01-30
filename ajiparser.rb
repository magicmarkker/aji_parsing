class Ajiparser
  require 'nokogiri'
  require_relative 'aji'

  def initialize(xml_doc, filename)
    @xml_doc = xml_doc
    @filename = filename
  end

  def parse
    doc = Nokogiri::XML(@xml_doc)
    File.open("parsedaji.xml", "w:UTF-8") do |f| 
      f.write '<?xml version="1.0" encoding="UTF-8"?>
    <xfdf xml:space="preserve" xmlns="http://ns.adobe.com/xfdf/">
      <f href="parsedaji.xml"/>
      <ids modified="[B@528af725" original="[B@50a25926"/>
      <annots>' + "\n\n"
      node = doc.root
      node.element_children.each do |n|
        case n.name
        when 'APAText'
          f.write convertAPAText(n)
        when 'APATextMarkup'
          #return convertAPATextMarkup(n)
          f.write convertAPATextMarkup(n)
        # when 'APAInk'
        #   f.write convertAPAInk(n)
        else
        end
      end
      f.write '</annots></xfdf>'
    end
  end

  def convertAPAText(n)
    #Get Rect
    rect = n.xpath('//rect').first
    @x = rect.attributes["x"].value
    @y = rect.attributes["y"].value
    @width = rect.attributes["width"].value
    @height = rect.attributes["height"].value

    @an = Aji.new
    @rect = @an.aji_to_xml({:x => @x.to_f, :y => @y.to_f, :w => @width.to_f, :h => @height.to_f})
    return text = '<text flags="nozoom,norotate" page="'"#{n.attributes['page'].value}"'" subject="Text" rect="'"#{@rect[:x1]},#{@rect[:y1]},#{@rect[:x2]},#{@rect[:y2]}"'" icon="Note" title="boardeffect"><contents>'"#{n.content.strip}"'</contents></text>'+ "\n\n"
  end

  def convertAPATextMarkup(n)
    #Get Rect
    rect = n.xpath('//rect').first
    @x = rect.attributes["x"].value
    @y = rect.attributes["y"].value
    @width = rect.attributes["width"].value
    @height = rect.attributes["height"].value

    @an = Aji.new
    @rect = @an.aji_to_xml({:x => @x.to_f, :y => @y.to_f, :w => @width.to_f, :h => @height.to_f})

    #Get Coords
    @co = Hash.new
    coords = n.search('//areas').first
    coords.element_children.each_with_index do |area, col|
      @co[col] = Hash.new
      area.element_children.each do |a|
        @co[col] = Hash.new
        @co[col][:x] = a.attributes["x"].value
        @co[col][:y] = a.attributes["y"].value
        @co[col][:width] = a.attributes["width"].value
        @co[col][:height] = a.attributes["height"].value
        @an = Aji.new
        @co[col][:aji] = @an.aji_to_xml({:x => @co[col][:x].to_f, :y => @co[col][:y].to_f, :w => @co[col][:width].to_f, :h => @co[col][:height].to_f})
      end
    end
    

    case n.attributes["textType"].value
    when 'Highlight'
      return text = '<highlight flags="print" color="#ffff00" opacity="1.0" page="'"#{n.attributes['page'].value}"'" subject="Highlight Text" rect="'"#{@rect[:x1]},#{@rect[:y1]},#{@rect[:x2]},#{@rect[:y2]}"'" title="boardeffect" coords="'"#{@co.collect{ |c, d| d[:aji].collect{ |a| a[1]}.join(',') }.join(',')}"'"/>' + "\n\n"
    when 'Underline'
      return text = '<underline flags="print" color="#0000ff" opacity="1.0" page="'"#{n.attributes['page'].value}"'" subject="Underline Text" rect="'"#{@rect[:x1]},#{@rect[:y1]},#{@rect[:x2]},#{@rect[:y2]}"'" title="boardeffect" coords="'"#{@co.collect{ |c, d| d[:aji].collect{ |a| a[1]}.join(',') }.join(',')}"'"/>'+ "\n\n"
    when 'Strikeout'
      return text = '<strikeout flags="print" color="#ffff00" opacity="1.0" page="'"#{n.attributes['page'].value}"'" subject="Highlight" rect="'"#{@rect[:x1]},#{@rect[:y1]},#{@rect[:x2]},#{@rect[:y2]}"'" title="boardeffect" coords="'"#{@co.collect{ |c, d| d[:aji].collect{ |a| a[1]}.join(',') }.join(',')}"'"/>'+ "\n\n"
    else
    end
  end

  def convertAPAInk(n)
    #Get Rect
    rect = n.xpath('//rect').first
    @x = rect.attributes["x"].value
    @y = rect.attributes["y"].value
    @width = rect.attributes["width"].value
    @height = rect.attributes["height"].value

    @an = Aji.new
    @rect = @an.aji_to_xml({:x => @x.to_f, :y => @y.to_f, :w => @width.to_f, :h => @height.to_f})

    #in the future try and get slope, and tell if its a straight line or not?
    
    return text = '<line style="solid" width="1.0" start="24.48,559.8933" flags="print" color="#ff0000" end="176.8,589.8133" opacity="1.0" tail="ClosedArrow" page="'"#{n.attributes['page'].value}"'" subject="Line" rect="'"#{@rect[:x1]},#{@rect[:y1]},#{@rect[:x2]},#{@rect[:y2]}"'" head="None" title="boardeffect" IT="LineArrow" caption="no"/>' + "\n\n"
  end
end

f = File.open('Exported_Annotations.xml')
a = Ajiparser.new(f, 'Exported_Annotations.xml')
a.parse
f.close