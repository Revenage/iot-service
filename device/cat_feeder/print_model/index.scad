use <build_plate.scad>
use <auger.scad>
use <tube.scad>
use <stepper28BYJ.scad>

/* [Auger] */

//The total amount of twist, in degrees
Auger_twist = 1100; //[90:1080]
//The radius of the auger's "flight" past the shaft
Auger_flight_radius = 20; //[5:50]
//The number of "flights" 
Auger_num_flights = 1; //[1:5]
//The height, from top to bottom of the "shaft"
Auger_flight_length = 119 - 17.5 - 1 - 4; //[10:200]
//The overhang angle your printer is capable of
Printer_overhang_capability = 20; //[0:40
//The thickness of perimeter support material
Auger_perimeter_thickness = 0.0; //[0:None, 0.8:Thin, 2:Thick]
//The radius of the auger's "shaft"
Auger_shaft_radius = 3; //[1:25]
//The thickness of the "flight" (in the direction of height)
Auger_flight_thickness = 1;  //[0.2:Thin, 1:Medium, 10:Thick]
Auger_handedness = "right";  //["right":Right, "left":Left]
//for display only, doesn't contribute to final object
build_plate_selector = 3; //[0:Replicator 2,1: Replicator,2:Thingomatic,3:Manual]
//when Build Plate Selector is set to "manual" this controls the build plate x dimension
build_plate_manual_x = 200; //[100:400]
//when Build Plate Selector is set to "manual" this controls the build plate y dimension
build_plate_manual_y = 200; //[100:400]

CatFeeder();

shift = 25;

innerDiametr = 46;

module bearing() {
    do = 10;
    di = 3;
    w = 4;
    difference() {
        cylinder(h=w, d = do, $fn=40);
        cylinder(h=w + 2, d = di, $fn=40);
    }
}

module nutM2(d = 4.32, h = 1.6) {
    cylinder(d=d, h=h, $fn = 6);
}

module nutM4(d = 7.66, h = 3.2) {
    cylinder(d=d, h=h, $fn = 6);
}

module drill2() {
    cylinder(d=2, h=10, $fn = 20);
}

module drill4() {
    cylinder(d=4, h=10, $fn = 20);
}

module topHolder() {
    
  di = innerDiametr - 1;
    
  difference() {
    union() {
    difference() {
        union() {
            cylinder(h=5, d = 14);
            cylinder(h=1, d = di);
        }
        
        //Bearing
        //color("blue", 0.5) bearing();
        translate([0, 0, -1])
            cylinder(h=4 + 1, d = 10, $fn=40);
        cylinder(h=4 + 2, d = 4, $fn=40);
    } 

    difference() {
    cylinder(h=5, d = di, $fn=60);
    translate([0, 0, -0.5])
        cylinder(h=6, d = di - 2, $fn=60);
    }
        
    for(n = [0 : 2]) {
         rotate([0, 0, n * 120])
            difference() {
                translate([6, -3, 0])
                    cube([di / 2 - 7, 6, 5]);
                translate([di / 2 - 5, 0, 3])
                rotate([90, 0, 90])  
                   hull() {
                        translate([0,4,0]) nutM2();
                        nutM2();
                    }
                }
    }
    
}

for(n = [0 : 2]) {        
         rotate([0, 90, n * 120])
            translate([-3, 0, 19])
            drill2();
    }
}

}

module backHolder(height) {
    r1 = (innerDiametr + 4) / 2 - 1;
    r2 = innerDiametr / 2 - 1;
    
   difference() { 
        
        union() {
            translate([0,0, height - 13])
                cylinder(h=13, d = 16.4);
            
            
            difference() {
            
                cylinder(h=height, r1 = r1 , r2 = r2, $fn=100);

            
                difference() {
                    translate([0,0, -1])
                        cylinder(h=height, r1 = r1 - 1, r2 = r2 - 1);
                    translate([0,-16, 3])
                        cube([50, 24, 10] , center = true);
                }
           }
    
    
           difference() {
                    translate([0,0, -height + 4])
                        cylinder(h=height - 4, r1 = r1, r2 = r1, $fn=100);
                
                    translate([0, 21, 0])
                        cube([50, 50, 10] , center = true);
                    
                }
                
          
              for(n = [0 : 4]) {
                rotate([n * 90 + 45,90,0])
                translate([0,-2.5, 6.5])
                cube([5, 5, 18]);
            }
             
          
          
    }
    
        union() {
            rotate([180,0,0])
            translate([17.5,8, -2])
            union() {
                
                hull() {
                    translate([0,-4,0]) nutM4();
                    nutM4();
                }
                translate([0,0,-2])
                drill4();
            }
            
            rotate([180,0,0])
            translate([-17.5,8, -2])
            union() {
               hull() {
                    translate([0,-4,0]) nutM4();
                    nutM4();
                }
                translate([0,0,-2])
                drill4();
            }
        }
        
        translate([0,0,-height + 1])
        difference() {
            cylinder(h=height, r1 = r1 + 2, r2 = r1 + 2, $fn=100);
            cylinder(h=height, r1 = r1, r2 = r1, $fn=100);
        }
        
        translate([0,0, height - 20])
            cylinder(h=30, d = 14, $fn=100);
    
        for(n = [0 : 4]) {
        rotate([n * 90 + 45,90,0])
        translate([2.5,0, 20])
        union() {
           
           hull() {
                translate([2,0,0]) nutM2();
                nutM2();
            }
            translate([0,0,-2])
            drill2();
        }
        }
        
        
         translate([0,-8, -shift - 5.6 + 8 + 0.5]) 
                stepper28BYJ(diff = 6);
      
    }
}

module Auger() {
//    cylinder(h=Auger_flight_length + 0.5 + 5, d = 3, $fn=40);
//    translate([0,0, Auger_flight_length]) //top center fat
//        cylinder(h=0.5, d = 5, $fn=40);
//    
//    translate([0,0, Auger_flight_length - 1]) // top flat
//        cylinder(h=1, d = innerDiametr); 
//    
//    auger(
//        r1 = Auger_shaft_radius,
//        r2 = Auger_shaft_radius + Auger_flight_radius,
//        h = Auger_flight_length,
//        overhangAngle = Printer_overhang_capability,
//        multiStart = Auger_num_flights,
//        flightThickness = Auger_flight_thickness,
//        turns = Auger_twist/360,
//        pitch=0,
//        supportThickness = Auger_perimeter_thickness,
//        handedness=Auger_handedness,
//        //$fn=50,
//        $fa=12,
//        $fs=5
//    );
//    
//    
//    cylinder(h=1, d = innerDiametr); // bootom flat
    
//    translate([0,-8, -shift - 5.6]) 
//        stepper28BYJ();
    
//    difference() {
//    translate([0,0, -10])
//        cylinder(h=11, d = 12, $fn=40);
//    
//    translate([0,-8, -shift - 5.6]) 
//        stepper28BYJ();
//        
//    union() {
//        translate([0,0, -7])
//            rotate([0, -90, 0])
//            drill2();
//    
//        translate([-3,0, -7])
//        rotate([0, -90, 0])
//            hull() {
//                translate([-2,0,0]) nutM2();
//                nutM2();
//            }
//       }
//    }
    
    
    
   
    
}

module CatFeeder() {
    
  
    //Drive
  
  
    //Backholder
  height = 8;
  translate([shift + 0.5 + height,0, 0])
    rotate([0, -90, 0])
        backHolder(height);
  
    // topHolder
//  translate([shift - 0.5 - Auger_flight_length,0, 0])
//      rotate([0, -90, 0])
//      topHolder();
  
   translate([shift,0, 0]) 
    rotate([0, -90, 0])
        color("red", 1) Auger();

    //color("silver", 0.3) tube(innerDiametr);
    
};
    
