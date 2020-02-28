import processing.core.*;
import processing.video.*;

public class Video extends PApplet {

  private final int w, h;
  static Movie movie;

  public Video(Movie _movie, int w, int h) {
    this.w = w;
    this.h = h;
    movie = _movie;
    movie.play();
    movie.pause();
  }
  
  public void settings() {
    size(w, h);
  }

  public void setup(){
    background(0);
    surface.setResizable(true);
    
  }

  public void draw() {    
    image(movie, 0, 0);
  }
}
