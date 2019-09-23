use <build_plate.scad>
use <auger.scad>
use <tube.scad>
use <stepper28BYJ.scad>
use <nutsAndDrill.scad>

/* [Auger] */

//The total amount of twist, in degrees
Auger_twist = 1000; //[90:1080]
//The radius of the auger's "flight" past the shaft
Auger_flight_radius = 20; //[5:50]
//The number of "flights" 
Auger_num_flights = 1; //[1:5]
//The height, from top to bottom of the "shaft"
Auger_flight_length = 119 - 17.5 - 1 - 4; //[10:200]
//The overhang angle your printer is capable of
Printer_overhang_capability = 10; //[0:40
//The thickness of perimeter support material
Auger_perimeter_thickness = 0.0; //[0:None, 0.8:Thin, 2:Thick]
//The radius of the auger's "shaft"
Auger_shaft_radius = 3; //[1:25]
//The thickness of the "flight" (in the direction of height)
Auger_flight_thickness = 1.2;  //[0.2:Thin, 1:Medium, 10:Thick]
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



module AugerFunctional() {
    
    color("red", 1)  
    union() {
    cylinder(h=Auger_flight_length + 0.5 + 5, d = 3, $fn=40);
    translate([0,0, Auger_flight_length]) //top center fat
        cylinder(h=0.5, d = 5, $fn=40);
    
    translate([0,0, Auger_flight_length - 1]) // top flat
        cylinder(h=1, d = innerDiametr); 
    
    auger(
        r1 = Auger_shaft_radius,
        r2 = Auger_shaft_radius + Auger_flight_radius,
        h = Auger_flight_length,
        overhangAngle = Printer_overhang_capability,
        multiStart = Auger_num_flights,
        flightThickness = Auger_flight_thickness,
        turns = Auger_twist/360,
        pitch=0,
        supportThickness = Auger_perimeter_thickness,
        handedness=Auger_handedness,
        //$fn=50,
        $fa=12,
        $fs=5
    );
    
    
    cylinder(h=1, d = innerDiametr); // bootom flat
    
    
    
    difference() {
    translate([0,0, -10])
        cylinder(h=11, d = 12, $fn=40);
    
    translate([0,-8, -shift - 5.6]) 
        stepper28BYJ();
        
    union() {
        translate([0,0, -7])
            rotate([0, -90, 0])
            drill2();
    
        translate([-3,0, -7])
        rotate([0, -90, 0])
            hull() {
                translate([-2,0,0]) nutM2();
                nutM2();
            }
       }
    }
}
    
}
