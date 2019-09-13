use <build_plate.scad>
use <auger.scad>
use <tube.scad>
use <stepper28BYJ.scad>

use <backHolder.scad>
use <topHolder.scad>
use <AugerFunctional.scad>



shift = 25;

innerDiametr = 46;

Auger_flight_length = 119 - 17.5 - 1 - 4; //[10:200]

module CatFeeder() {
  
    //Backholder
//   height = 8;
//   translate([shift + 0.5 + height,0, 0])
//    rotate([0, -90, 0])
//        color("blue", 1)
//        backHolder(height);
  
    // topHolder
  translate([shift - 0.5 - Auger_flight_length,0, 0])
      rotate([0, -90, 0])
      color("blue", 1)
      topHolder();
//  
    //Auger
//   rotate(a=$t * 360, v=[1,0,0])
//   translate([shift,0, 0]) 
//    rotate([0, -90, 0])
//        AugerFunctional();
//        
//   //Step Driver
//    translate([shift,0, 0]) 
//    rotate([0, -90, 0])
//    color("yellow", 0.3) translate([0,-8, -shift - 5.6])
//        stepper28BYJ();
//
//    // Tube
//    color("silver", 0.3) tube(innerDiametr);
    
};
    




CatFeeder();