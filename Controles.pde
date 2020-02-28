/*
  Proyecto: Instalación interactiva, proyecto de fin de curso Vanessa Antonella Correa.
 Reprodcutor de audio y video controlado por sensores ultrasónicos via broker mqtt
 Sensores: HC-SR04
 Cliente MQTT: Wemos mini D1
 */
import processing.core.*;
import processing.video.*;
import ddf.minim.*;
import controlP5.*;
import mqtt.*;

MQTTClient client;
Adapter adapter;

ControlP5 cp5;

Minim minim;
AudioPlayer playerOne, playerTwo, playerThree; 

Movie myMovie;

Video video;

class Adapter implements MQTTListener {
  void clientConnected() {
    println("client connected");

    client.subscribe("sala_1");
  }

  void messageReceived(String topic, byte[] payload) {
    String[] data;
    data = match(new String(payload), "sensor_1");
    if (data != null) {
      playerOne.play();
      playerTwo.play();
      println("new message: " + topic + " - " + new String(payload));
    }
    data = match(new String(payload), "sensor_2");
    if (data != null) {
      playerOne.play();
      playerTwo.play();
      play_Movie();
      println("new message: " + topic + " - " + new String(payload));
    }
  }

  void connectionLost() {
    println("connection lost");
  }
}

void movieEvent(Movie m) {
  m.read();
}

void setup() {
  background(0);

  adapter = new Adapter();
  client = new MQTTClient(this, adapter);
  client.connect("mqtt://192.168.2.2", "nothing");

  size(350, 700);
  
  noStroke();
  surface.setResizable(true);

  minim = new Minim(this);
  cp5 = new ControlP5(this);

  playerOne = minim.loadFile(sketchPath("") + "/mp3/43-gritos.mp3");
  playerTwo = minim.loadFile(sketchPath("") + "/mp3/max-richter-she-remembers.mp3");
  float vol = 0.88;
  vol = map(vol, 0.0f, 1.0f, -30.0, 20.0);
  playerTwo.setGain(vol);
  
  playerThree = minim.loadFile(sketchPath("") + "/mp3/efecto-de-sonido-respiracion.mp3");

  myMovie = new Movie(this, sketchPath("") + "/video/VIDEO FINAL.mpeg");

  String[] args = {"--display=1", "--location=0,0", "Video"};
  video = new Video(myMovie, 1280, 720);

  PApplet.runSketch(args, video);

  createGUI();
}

void draw() {

  background(0);
  cp5.getController("posicion4").setValue((float)Video.movie.time());
  if (playerOne.isPlaying()) {
    cp5.getController("posicion1").setValue((float)playerOne.position()/1000);
    cp5.getController("toggle1").setValue(1);
  } else if (!playerOne.isPlaying()) cp5.getController("toggle1").setValue(0);
  if (playerTwo.isPlaying()) {
    cp5.getController("posicion2").setValue((float)playerTwo.position()/1000);
    cp5.getController("toggle2").setValue(1);
  } else if (!playerTwo.isPlaying()) cp5.getController("toggle2").setValue(0);
  if (playerThree.isPlaying()) {
    cp5.getController("posicion3").setValue((float)playerThree.position()/1000);
    cp5.getController("toggle3").setValue(1);
  } else if (!playerThree.isPlaying()) cp5.getController("toggle3").setValue(0);
  if((Video.movie.duration() - Video.movie.time()) < 35){
    playerThree.play();
  }
}

void keyPressed() {
  if (key == 'r') {
    playerOne.rewind();
  }
  if (key == 'q') {
    playerOne.pause();
    playerOne.rewind();

    playerTwo.pause();
    playerTwo.rewind();

    playerThree.pause();
    playerThree.rewind();
    
    stop_Movie();
    rwd_Movie();
  }
}

public void play_playerOne() {
  playerOne.play();
}

public void stop_playerOne() {
  playerOne.pause();
}

public void rwd_playerOne() {
  playerOne.rewind();
  cp5.getController("posicion1").setValue((float)playerOne.position()/1000);
}

public void set_volume_playerOne(float vol) {
  vol = map(vol, 0.0f, 1.0f, -30.0, 20.0);
  playerOne.setGain(vol);
}

public void play_playerTwo() {
  playerTwo.play();
  set_volume_playerTwo(0.88);
}

public void stop_playerTwo() {
  playerTwo.pause();
}

public void rwd_playerTwo() {
  playerTwo.rewind();
  cp5.getController("posicion2").setValue((float)playerTwo.position()/1000);
}

public void set_volume_playerTwo(float vol) {
  vol = map(vol, 0.0f, 1.0f, -30.0, 20.0);
  playerTwo.setGain(vol);
}

public void play_playerThree() {
  playerThree.play();
}

public void stop_playerThree() {
  playerThree.pause();
}

public void rwd_playerThree() {
  playerThree.rewind();
  cp5.getController("posicion2").setValue((float)playerThree.position()/1000);
}

public void set_volume_playerThree(float vol) {
  vol = map(vol, 0.0f, 1.0f, -30.0, 20.0);
  playerThree.setGain(vol);
}

public void play_Movie() {
  Video.movie.play();
}

public void stop_Movie() {
  Video.movie.pause();
}

public void rwd_Movie() {
  Video.movie.jump(0);
  cp5.getController("posicion3").setValue((float)Video.movie.time());
}


void createGUI() {

  //cp5.setAutoDraw(true);
  Accordion accordion;

  int gui_w = 290;
  int gui_x = 30;
  int gui_y = 15;

  float mult_fg = 1f;
  float mult_active = 2f;
  float CR = 96;
  float CG = 16;
  float CB =  0;

  int col_bg    ;
  int col_fg    ;
  int col_active;

  col_bg     = color(250);
  col_fg     = color(CR*mult_fg, CG*mult_fg, CB*mult_fg);
  col_active = color(CR*mult_active, CG*mult_active, CB*mult_active);

  int col_group = color(8, 224);

  CColor theme = ControlP5.getColor();
  theme.setForeground(col_fg);
  theme.setBackground(col_bg);
  theme.setActive(col_active);

  int sx, sy, px, py;
  sx = 100; 
  sy = 14; 

  int dy_group = 20;

  ////////////////////////////////////////////////////////////////////////////
  // GUI - FLUID
  ////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////
  // GUI - GROUP 1
  ////////////////////////////////////////////////////////////////////////////
  Group group_playerOne = cp5.addGroup("Audio 1");
  {
    group_playerOne.setHeight(20).setSize(gui_w, 150)
      .setBackgroundColor(col_group).setColorBackground(col_group);
    group_playerOne.getCaptionLabel().align(CENTER, CENTER);

    px = 15; 
    py = 15;

    cp5.addTextfield("Pista 1").moveTo(group_playerOne).setSize(sx*2, sy).setPosition(px, py);
    py += sy + dy_group;

    cp5.addButton("play1")
      .moveTo(group_playerOne).plugTo(this, "play_playerOne"     )
      .setSize(80, 18)
      .setPosition(px, py)
      .setCaptionLabel("Play");

    cp5.addButton("stop1")
      .moveTo(group_playerOne)
      .plugTo(this, "stop_playerOne"     )
      .setSize(80, 18)
      .setPosition(px+sx, py)
      .setCaptionLabel("Stop");

    cp5.addKnob("volume1")
      .moveTo(group_playerOne)
      .setSize(60, 60)
      .setPosition((px+sx)*1.8, py)
      .setCaptionLabel("Vol")
      .setRange(0.0f, 1.0f)
      .setValue(map(playerOne.getGain(), -30.0, 20.0, 0.0f, 1.0f))
      .plugTo(this, "set_volume_playerOne");


    py += sy + dy_group;

    cp5.addButton("rwd1")
      .moveTo(group_playerOne)
      .plugTo(this, "rwd_playerOne"     )
      .setSize(80, 18).setPosition(px, py)
      .setCaptionLabel("Retroceder");

    cp5.addToggle("toggle1")
      .setCaptionLabel("Audio On/Off")
      .moveTo(group_playerOne)
      .setPosition(px+sx, py)
      .setSize(60, 18)
      .setValue(false)
      .setMode(ControlP5.SWITCH)
      ;
    py += (sy *2 ) + dy_group;
    cp5.addSlider("posicion1")
      .moveTo(group_playerOne)
      .setSize(sx * 2, sy)
      .setPosition(px, py)
      .setCaptionLabel(str((float)playerOne.length()/60000))
      .setRange(0.0f, (float)playerOne.length()/1000)
      .setValue(0).plugTo(this, "get_position_playeOne").
      setSliderMode(Slider.FLEXIBLE);
  }
  ////////////////////////////////////////////////////////////////////////////
  // GUI - GROUP 2
  ////////////////////////////////////////////////////////////////////////////
  Group group_playerTwo = cp5.addGroup("Audio 2");
  {
    group_playerTwo.setHeight(20).setSize(gui_w, 150)
      .setBackgroundColor(col_group).setColorBackground(col_group);
    group_playerTwo.getCaptionLabel().align(CENTER, CENTER);

    px = 15; 
    py = 15;

    cp5.addTextfield("Pista 2").moveTo(group_playerTwo).setSize(sx*2, sy).setPosition(px, py);

    py += sy + dy_group;

    cp5.addButton("play2").moveTo(group_playerTwo).plugTo(this, "play_playerTwo"     ).setSize(80, 18).setPosition(px, py).setCaptionLabel("Play");
    cp5.addButton("stop2").moveTo(group_playerTwo).plugTo(this, "stop_playerTwo"     ).setSize(80, 18).setPosition(px+sx, py).setCaptionLabel("Stop");

    cp5.addKnob("volume2").moveTo(group_playerTwo).setSize(60, 60).setPosition((px+sx)*1.8, py).setCaptionLabel("Vol")
      .setRange(0.0f, 1.0f).setValue(map(playerTwo.getGain(), -30.0, 20.0, 0.0f, 1.0f)).plugTo(this, "set_volume_playerTwo");

    py += sy + dy_group;

    cp5.addButton("rwd2").moveTo(group_playerTwo).plugTo(this, "rwd_playerTwo"     ).setSize(80, 18).setPosition(px, py).setCaptionLabel("Retroceder");

    cp5.addToggle("toggle2")
      .setCaptionLabel("Audio On/Off")
      .moveTo(group_playerTwo)
      .setPosition(px+sx, py)
      .setSize(60, 18)
      .setValue(false)
      .setMode(ControlP5.SWITCH)
      ;
    py += (sy * 2) + dy_group;

    cp5.addSlider("posicion2").moveTo(group_playerTwo).setSize(sx * 2, sy).setPosition(px, py).setCaptionLabel(str((float)playerTwo.length()/60000))
      .setRange(0.0f, (float)playerTwo.length()/1000).setValue(0).plugTo(this, "get_position_playeTwo").setSliderMode(Slider.FLEXIBLE);
  }
  
  ////////////////////////////////////////////////////////////////////////////
  // GUI - GROUP 3
  ////////////////////////////////////////////////////////////////////////////
  Group group_playerThree = cp5.addGroup("Audio 3");
  {
    group_playerThree.setHeight(20).setSize(gui_w, 150)
      .setBackgroundColor(col_group).setColorBackground(col_group);
    group_playerThree.getCaptionLabel().align(CENTER, CENTER);

    px = 15; 
    py = 15;

    cp5.addTextfield("Pista 3").moveTo(group_playerThree).setSize(sx*2, sy).setPosition(px, py);

    py += sy + dy_group;

    cp5.addButton("play3").moveTo(group_playerThree).plugTo(this, "play_playerThree"     ).setSize(80, 18).setPosition(px, py).setCaptionLabel("Play");
    cp5.addButton("stop3").moveTo(group_playerThree).plugTo(this, "stop_playerThree"     ).setSize(80, 18).setPosition(px+sx, py).setCaptionLabel("Stop");

    cp5.addKnob("volume3").moveTo(group_playerThree).setSize(60, 60).setPosition((px+sx)*1.8, py).setCaptionLabel("Vol")
      .setRange(0.0f, 1.0f).setValue(map(playerThree.getGain(), -30.0, 20.0, 0.0f, 1.0f)).plugTo(this, "set_volume_playerThree");

    py += sy + dy_group;

    cp5.addButton("rwd3").moveTo(group_playerThree).plugTo(this, "rwd_playerThree"     ).setSize(80, 18).setPosition(px, py).setCaptionLabel("Retroceder");

    cp5.addToggle("toggle3")
      .setCaptionLabel("Audio On/Off")
      .moveTo(group_playerThree)
      .setPosition(px+sx, py)
      .setSize(60, 18)
      .setValue(false)
      .setMode(ControlP5.SWITCH)
      ;
    py += (sy * 2) + dy_group;

    cp5.addSlider("posicion3").moveTo(group_playerThree).setSize(sx * 2, sy).setPosition(px, py).setCaptionLabel(str((float)playerThree.length()/60000))
      .setRange(0.0f, (float)playerThree.length()/1000).setValue(0).plugTo(this, "get_position_playeThree").setSliderMode(Slider.FLEXIBLE);
  }
  
  ////////////////////////////////////////////////////////////////////////////
  // GUI - GROUP 4
  ////////////////////////////////////////////////////////////////////////////

  Group group_Movie = cp5.addGroup("Video");
  {
    group_Movie.setHeight(20).setSize(gui_w, 150)
      .setBackgroundColor(col_group).setColorBackground(col_group);
    group_Movie.getCaptionLabel().align(CENTER, CENTER);

    px = 15; 
    py = 15;

    cp5.addTextfield("video").moveTo(group_Movie).setSize(sx*2, sy).setPosition(px, py).setCaptionLabel("Video");
    py += sy + dy_group;

    cp5.addButton("play4").moveTo(group_Movie).plugTo(this, "play_Movie"     ).setSize(80, 18).setPosition(px, py).setCaptionLabel("Play");
    cp5.addButton("stop4").moveTo(group_Movie).plugTo(this, "stop_Movie"     ).setSize(80, 18).setPosition(px+sx, py).setCaptionLabel("Stop");

    py += sy + dy_group;

    cp5.addButton("rwd4").moveTo(group_Movie).plugTo(this, "rwd_Movie"     ).setSize(80, 18).setPosition(px, py).setCaptionLabel("Retroceder");

    py += sy + dy_group;
    cp5.addSlider("posicion4").moveTo(group_Movie).setSize(sx * 2, sy).setPosition(px, py).setCaptionLabel(str((float)Video.movie.duration()/60))
      .setRange(0.0f, (float)Video.movie.duration()).setValue(0).plugTo(this, "").setSliderMode(Slider.FLEXIBLE);
  }
  ////////////////////////////////////////////////////////////////////////////
  // GUI - ACCORDION
  ////////////////////////////////////////////////////////////////////////////
  accordion = cp5.addAccordion("acc")
    .setPosition(gui_x, gui_y)
    .setWidth(gui_w).setSize(gui_w, height)
    .setCollapseMode(Accordion.MULTI)
    .addItem(group_playerOne)
    .addItem(group_playerTwo)
    .addItem(group_playerThree)
    .addItem(group_Movie);
  accordion.open();

  // use Accordion.MULTI to allow multiple group 
  // to be open at a time.
  accordion.setCollapseMode(Accordion.MULTI);
}
