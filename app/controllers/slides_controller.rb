class SlidesController < ApplicationController
  # GET /slides
  # GET /slides.xml

  def about
    @header = "How Healthy is Otley? Live!"
    @subtitle = "Why not join in the great experiment? Find us in the Multi-Media Room"
  end

  # GET /slides/1
  # GET /slides/1.xml
  def show
    @subtitle = "Why not join in the great experiment? Find us in the Multi-Media Room"
    begin
      @slide = Slide.question(params[:id])
    rescue Exception => e
      @slide = nil # do something better here!
    ensure
      @header = "How Healthy is Otley? Live!"
    end
  end

end
