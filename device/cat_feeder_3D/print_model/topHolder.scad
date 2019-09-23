use <build_plate.scad>
use <auger.scad>
use <tube.scad>
use <stepper28BYJ.scad>
use <nutsAndDrill.scad>
use <bearing.scad>

shift = 25;

innerDiametr = 46;

module topHolder() {
    
  di = innerDiametr - 1;
    
  difference() {
    union() {
    difference() {
        union() {
            cylinder(h=5, d = 14, $fn=200);
            cylinder(h=1, d = di, $fn=200);
        }
        
        //Bearing
        //color("blue", 0.5) bearing();
        translate([0, 0, -1])
            cylinder(h=4 + 1, d = 10, $fn=200);
        cylinder(h=4 + 2, d = 4, $fn=200);
    } 

    difference() {
    cylinder(h=5, d = di, $fn=200);
    translate([0, 0, -0.5])
        cylinder(h=6, d = di - 2, $fn=200);
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
            translate([-3, 0, 15])
            drill2();
    }
}

}