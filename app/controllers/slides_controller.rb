class SlidesController < ApplicationController
  # GET /slides
  # GET /slides.xml

  def about
    @header = "Toast Dropping Experiment - Live!"
    @subtitle = "Why not join in the great experiment? Find us in the Multi-Media Room"
  end

  # GET /slides/1
  # GET /slides/1.xml
  def show
    @subtitle = "Why not join in the great experiment? Find us in the Multi-Media Room"
    begin
      @slide = Slide.question(params[:id])
    rescue Exception => e
      @slide = nil
    ensure
      @header = "Is Otley Average? Live!"
    end
  end

end
