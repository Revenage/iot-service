use <build_plate.scad>
use <auger.scad>
use <tube.scad>
use <stepper28BYJ.scad>
use <nutsAndDrill.scad>

shift = 25;

innerDiametr = 46;

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