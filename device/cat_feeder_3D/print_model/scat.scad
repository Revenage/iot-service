   
module scat() {
    
   
    translate([-77,24, -30]) 
    difference() {
        cube([12, 12, 12]);
        translate([2,2, -2])
         cube([12, 12, 12]);
        translate([6, 0, -8])
         rotate([0, -45, 0])
         cube([20, 12, 10]);
        
        rotate([0, 90, 0])
        translate([-6, 6, -1])
        cylinder(h = 4, d = 4);
    }
    
    
    translate([-77, -36, -30]) 
    difference() {
        cube([12, 12, 12]);
        translate([2,-2, -2])
         cube([12, 12, 12]);
        translate([6, 0, -8])
         rotate([0, -45, 0])
         cube([20, 12, 10]);
        
        rotate([0, 90, 0])
        translate([-6, 6, -1])
        cylinder(h = 4, d = 4);
    }
    
    
    difference() {
           difference() {
            translate([-30,0, 0]) 
            rotate([0, -130, 0])
            hull() {
                translate([20,0,0]) cylinder(h = 110, d = 50, center = false);
                cylinder(h = 110, d = 50, center = false);
            }
            
            translate([-50,0, 16]) 
                cube ([60, 60 , 40], center = true);
            translate([-117.1,5, -40]) 
                cube ([60, 60 , 100], center = true);

            translate([-107.1,5, 0]) 
                cube ([60, 60 , 60], center = true);
           
            }

            
       
           difference() {
                translate([-30,0, 0]) 
                rotate([0, -130, 0])
                hull() {
                    translate([20,0,0]) cylinder(h = 112, d = 48, center = false);
                    cylinder(h = 112, d = 48, center = false);
                }
             
           }
           
           }
    }