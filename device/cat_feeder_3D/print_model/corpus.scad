 use <tube.scad>   
 use <stepper28BYJ.scad>
 use <scat.scad>   

shift = 25;
Auger_flight_length = 119 - 17.5 - 1 - 4;

module desk(w = 30, h = 40) {
   cube([10, w, h], true);
}

module topdesk(w = 30, h = 40) {
   translate([-13, 0, 40]) 
   rotate([0, 90, 0])
   desk(w, h);
}


module firsdesk(w = 30, h = 40) {
        translate([-83, 0, -25]) 
        rotate([0, 0, 0])
        desk(w, h);
}


module bank(){
    translate([0, 0, 45]) 
   //rotate([0, 90, 0])
   cylinder(h = 500, d = 100, center = false, $fn = 100);
    
}

module lrdesk(w = 30, h = 40) {
   translate([0, 45, -16]) 
   rotate([0, 0, 90])
   desk(w, h);
}

module t(di1 = 46, cutModel = false) {
    
    difference() {
        color("silver", 0.3) tube(di1 = di1, cutModel =      cutModel);
        
        translate([-Auger_flight_length + 27,-30, -45]) 
        cube([35, 60, 40]);
   }
    }
    
    
module leg() {
    rotate([90, 0, -30])
    translate([-60, -220, -110]) 
        difference() {
            cylinder(h = 10, d = 500, center = true, $fn = 100);
            cylinder(h = 12, d = 450, center = true, $fn = 100);
        }
}
    
module corpus() {
    t();
    %bank();
    
    
   
    
    difference() {
        union() {
            
            
           scat();
            //Step Driver
           translate([shift,0, 0]) 
           rotate([0, -90, 0])
           color("yellow", 0.3) translate([0,-8, -shift -       5.6])
               stepper28BYJ();
            
           translate([5,0, 0])
           topdesk(102, 160);
            
            
               
            difference() {
            firsdesk(102, 120);
            hull() {
            translate([-10, 0, 0])
            difference() {
                scat();
                translate([-60,0, 0]) 
                cube([100, 80, 60], center= true);
           }
           difference() {
                scat();
                translate([-60,0, 0]) 
                cube([100, 80, 60], center= true);
           }
           }
           }
           
           translate([-16, 0, 0])
           mirror([1, 0, 0]) firsdesk(102, 120);
        }
        
        t(cutModel = true);
    }
    
    
    difference() {
        union() {
        leg();
        mirror([0,1,0]) leg();
        }
        
        translate([30, 0, -450]) 
        cube([600, 600, 600], center = true);
    
    }

   

};


corpus();