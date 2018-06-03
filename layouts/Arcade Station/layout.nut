//
// Attract-Mode Front-End - Arcade Station
// Based on "Game Station" by kent79
// http://forum.attractmode.org/index.php?topic=505.0
//
class UserConfig {
      </ label="Arcade Station Mode", help="If select Expert mode, logo, wheel logo & background color will be accroding by layout.nut file.", options="Simple, Expert", order=1 /> mode="Simple";
      </ label="Play Video Sound", help="Play Video Sound", options="Yes,No", order=2 /> sound="Yes";     
      </ label="Red (R) (0-255) Color", help="Value of red component for background color (simple mode only)", option="0", order=3 /> red=5;
      </ label="Green (G) (0-255) Color", help="Value of green component for background color (simple mode only)", option="0", order=4 /> green=67;
      </ label="Blue (B) (0-255) Color", help="Value of blue component for background color (simple mode only)", option="40", order=5 />  blue=110;
      </ label="Display Time", help="Display current time", options="Yes,No", order=6 /> enable_time="No";      
      </ label="Display Logo Option", help="The artwork to logo", options="Wheel Only, Wheel + System, System Only", order=7 /> wheel_logo="System only";      
//      </ label="Flyer Aspect Ratio", help="Flyer preserve aspect ratio", options="Yes,No", order=8 /> ratio="No";
      </ label="Display Move Strip", help="Display move strip. Remember to create a new artwork folder called [flyer2]", options="Yes,No", order=9 /> enable_strip="No";
          
 }  

local my_config = fe.get_config();
local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;
fe.layout.font="roboto";

fe.load_module( "fade" );
fe.load_module("animate");

local TRIGGER = Transition.EndNavigation;

// Convert user-supplied values to integers (because one might enter "cow" or
// anything, really, for a value, we need to sanitize by assuming positive 0).
 local bgRed=abs(("0"+my_config["red"]).tointeger());
 local bgGreen=abs(("0"+my_config["green"]).tointeger());
 local bgBlue=abs(("0"+my_config["blue"]).tointeger());

// Ensure we don't allow values over 255: if greater than, set to 255.
 bgRed=(bgRed>255 ? bgRed % 255 : bgRed);
 bgGreen=(bgGreen>255 ? bgGreen % 255 : bgGreen);
 bgBlue=(bgBlue>255 ? bgBlue % 255 : bgBlue);

//No Available Image
 local no_available = fe.add_artwork("no_available_image.png", flx*0.735, fly*0.35, flw*0.12, flh*0.16 );
 no_available.alpha = 230;


// Game List
 local lb = fe.add_listbox( flx*0.59, fly*0.11, flw*0.41, flh*0.691 );
 lb.charsize = 28;
 lb.align = Align.Left;
 lb.rows=9;
 lb.set_sel_rgb( 240, 240, 240 );
 lb.set_selbg_rgb( bgRed, bgGreen, bgBlue );
 lb.set_rgb( 205, 205, 205 );


// Bottom Background
 local lb = fe.add_text( "", 0, fly*0.8, flw, flh*0.231);
 lb.set_bg_rgb( bgRed, bgGreen, bgBlue );

// Fill an entire surface with our snap at a resolution of 640x480
 local surface = fe.add_surface( 640, 480 ); 
 local snap = surface.add_artwork("snap", 0, 0, 640, 480);
 snap.trigger = TRIGGER;
 snap.preserve_aspect_ratio = true;
 surface.set_pos( flx*0, fly*0.11, flw*0.59, flh*0.69 );
 if ( my_config["sound"] == "No" ){
     snap.video_flags = Vid.NoAudio;
 }

// Bottom Shadow
 local bgBottom = fe.add_image ("black.png",0, fly*0.963, flw, flh*0.04);
 bgBottom.alpha = 30;

// Top Background
 local lt = fe.add_text( "", 0, 0, flw, flh*0.111);
 lt.set_bg_rgb( bgRed, bgGreen, bgBlue );

// Game name text. We do this in the layout as the frontend doesn't chop up titles with a forward slash
 function gamename( index_offset ) {
  local s = split( fe.game_info( Info.Title, index_offset ), "(/[" );
 	if ( s.len() > 0 ) return s[0];
  return "";
}

 local gametitle = fe.add_text( gamename ( 0 ), flx*-0.015, fly*0.805, flw*0.9, flh*0.1 );
       gametitle.align = Align.Left;
       gametitle.alpha = 235;

//Game Information Text
 local year = fe.add_text( "© [Year] [Manufacturer]", flx*0.015, fly*0.905, flw*0.56, flh*0.04  );
 year.alpha = 150;
 year.align = Align.Left;

 local bgListCount = fe.add_image ("white.png",flx*0.6, fly*0.913, flw*0.13, flh*0.03);
 bgListCount.alpha = 225;

 local listCountText = fe.add_text("Played:[PlayedCount]" ,flx*0.594, fly*0.912, flw*0.14, flh*0.03);
 listCountText.set_rgb( 0, 0, 0 );
 listCountText.alpha = 240;

 local bgPlayer = fe.add_image ("black.png",flx*0.73, fly*0.913, flw*0.13, flh*0.03);
 bgPlayer.alpha = 215;

 local playerText = fe.add_text( "[Players] Player(s)", flx*0.73, fly*0.912, flw*0.13, flh*0.03  );
 playerText.alpha = 225;

 local titleText = fe.add_text( "[DisplayName] > [FilterName] > [Title] [ [Name] ]", flx*0.05, fly*0.97, flw*0.9, flh*0.022  );
 titleText.alpha = 210;

// Genre_image
 local genre_image = fe.add_image("unknown.png", flx*0.88, fly* 0.817, flw*0.098, flh*0.13 );

 class GenreImage
   {
    mode = 1;       //0 = first match, 1 = last match, 2 = random
    supported = {
        //filename : [ match1, match2 ]
        "act": [ "action","platformer", "platform" ],
        "avg": [ "adventure" ],
        "ftg": [ "fighting", "fighter", "Beat-'em-Up" ],
        "pzg": [ "puzzle" ],
        "rcg": [ "racing", "driving" ],
        "rpg": [ "rpg", "role playing", "role-playing", "role playing game" ],
        "stg": [ "shooter", "shmup", "Shoot-'em-Up" ],
        "spt": [ "sports", "boxing", "golf", "baseball", "football", "soccer" ],
        "slg": [ "strategy"]
    }

    ref = null;
    constructor( image )
    {
        ref = image;
        fe.add_transition_callback( this, "transition" );
    }
    
    function transition( ttype, var, ttime )
    {
        if ( ttype == Transition.ToNewSelection || ttype == Transition.ToNewList )
        {
            local cat = " " + fe.game_info(Info.Category, var).tolower();
            local matches = [];
            foreach( key, val in supported )
            {
                foreach( nickname in val )
                {
                    if ( cat.find(nickname, 0) ) matches.push(key);
                }
            }
            if ( matches.len() > 0 )
            {
                switch( mode )
                {
                    case 0:
                        ref.file_name = "images/" + matches[0] + ".png";
                        break;
                    case 1:
                        ref.file_name = "images/" + matches[matches.len() - 1] + ".png";
                        break;
                    case 2:
                        local random_num = floor(((rand() % 1000 ) / 1000.0) * ((matches.len() - 1) - (0 - 1)) + 0);
                        ref.file_name = "images/" + matches[random_num] + ".png";
                        break;
                }
            } else
            {
                ref.file_name = "images/unknown.png";
            }
        }
    }
}

GenreImage(genre_image);

//Display current time
if ( my_config["enable_time"] == "Yes" ){
  local dt = fe.add_text( "", flx*0.765, fly*0.002, flw*0.3, flh*0.095 );
  dt.align = Align.Left;
  dt.alpha = 230;

  local clock = fe.add_image ("clock.png",flx*0.74, fly*0.017, flw*0.048, flh*0.075);
  clock.alpha = 230;

function update_clock( ttime ){
  local now = date();
  dt.msg = format("%02d", now.hour) + ":" + format("%02d", now.min );
}
  fe.add_ticks_callback( this, "update_clock" );
}

//Game List Animation
 ::OBJECTS <- {
 wheelLogo = fe.add_artwork("wheel", flx*0.025, fly*0.03, flw*0.23, flh*0.13),
 logo = fe.add_image("[Emulator]", flx*0.0265, fly*0.03, flw*0.18, flh*0.09 ),
 marquee = fe.add_artwork("marquee", flx*-0.2, fly*0.67, flw*0.18, flh*0.1), 
 moveStrip = fe.add_artwork("flyer2", flx*-1, fly*0.8, flw, flh*0.163 ),
 }



::OBJECTS["marquee"].trigger = TRIGGER;
::OBJECTS["moveStrip"].trigger = TRIGGER;

//Animation for Global & Expert Mode

 local move_shrink1 = {
    when = Transition.ToNewList ,property = "scale", start = 1.8, end = 1.0, time = 1500, tween = Tween.Bounce
 }
 local move_shrink2 = {
    when = Transition.ToNewSelection ,property = "scale", start = 1.8, end = 1.0, time = 1500, tween = Tween.Bounce
 } 
 local move_marquee1 = {
    when = Transition.ToNewSelection ,property = "x", start = flx*-0.3, end = 0, time = 900
 }
 local move_marquee2 = {    
    when = Transition.ToNewSelection ,property = "x", start = 0, end = flx*-0.3, time = 1600, delay = 3600
 }
 local move_strip1 = {    
    when = Transition.ToNewSelection ,property = "x", start = flx*-1 end = flx*0, time = 3000, delay = 3600
 }
 local move_strip2 = {    
    when = Transition.ToNewSelection ,property = "x", start = flx*-1 end = flx, time = 1, delay = 1
 }

//Animation

if ( my_config["wheel_logo"] == "Wheel + System" ){
 OBJECTS.logo.visible = true;
 OBJECTS.logo.preserve_aspect_ratio = true;
 OBJECTS.wheelLogo.visible = true;
}

else if ( my_config["wheel_logo"] == "System Only" ){
 OBJECTS.logo.visible = true;
 OBJECTS.logo.preserve_aspect_ratio = true;
 OBJECTS.wheelLogo.visible = false;
}

else if ( my_config["wheel_logo"] == "Wheel Only" ){
 OBJECTS.logo.visible = false;
 OBJECTS.wheelLogo.visible = true;
}

if ( my_config["enable_strip"] == "No" ){
 OBJECTS.moveStrip.visible = false;
 }

 animation.add( PropertyAnimation( OBJECTS.wheelLogo, move_shrink1 ) );
 animation.add( PropertyAnimation( OBJECTS.wheelLogo, move_shrink2 ) );
 //animation.add( PropertyAnimation( OBJECTS.logo, move_shrink1 ) );
 //animation.add( PropertyAnimation( OBJECTS.logo, move_shrink2 ) );
 animation.add( PropertyAnimation( OBJECTS.marquee, move_marquee1 ) );
 animation.add( PropertyAnimation( OBJECTS.marquee, move_marquee2 ) );
 animation.add( PropertyAnimation( OBJECTS.moveStrip, move_strip2 ) );
 animation.add( PropertyAnimation( OBJECTS.moveStrip, move_strip1 ) );

//Expert Mode to Setup Logo, Wheel Logo & Background Color
//Please refer as below sample to be setup and remember put system image file in correct path

//case "MAME":						System name, Input system name. eg. mame, snes, nes, md .........    
//OBJECTS.logo.file_name = "";				System logo file names, if you want to show system logo, please type system logo file name. Left it empty if want to show game wheel logo      
//lt.set_bg_rgb( 155, 0, 40 );                          Color of top background  
//lb.set_bg_rgb( 155, 0, 40 );				Color of bottom background
//OBJECTS.gameListBox.set_selbg_rgb( 155, 0, 40 );	Color of list box selection
//OBJECTS.gameListList2.set_rgb( 155, 0, 40 );		Color of game list number 
//break;

if ( my_config["mode"] == "Expert" ){
 function transition_callback(ttype, var, ttime)
  {
    switch ( ttype )
    {
        case Transition.ToNewList:
            switch ( fe.list.name )
            {              
		case "MAME":
                OBJECTS.logo.file_name = "";
		lt.set_bg_rgb( 155, 0, 40 );
		lb.set_bg_rgb( 155, 0, 40 );
		OBJECTS.gameListBox.set_selbg_rgb( 155, 0, 40 );
		OBJECTS.gameListList2.set_rgb( 155, 0, 40 );
                break;
		case "NES":
                OBJECTS.logo.file_name = "nes.png";
		lt.set_bg_rgb( 0, 150, 136 );
		lb.set_bg_rgb( 0, 150, 136 );
		OBJECTS.gameListBox.set_selbg_rgb( 0, 150, 136 );
		OBJECTS.gameListList2.set_rgb( 0, 150, 136 );
                break;	
			}
			break;
    }
  }
}

function fade_transitions( ttype, var, ttime ) {
 switch ( ttype ) {
  case Transition.ToNewList:
  case Transition.ToNewSelection:
      gametitle.msg = gamename ( var );  
  break;
  }
 return false;
}

fe.add_transition_callback("transition_callback" );
fe.add_transition_callback( "fade_transitions" );