    
module tube(di1 = 46) {
  w = 2;
  di2 = di1 + 4;

  do1 = di1 + (w*2);
  do2 = di2 + (w*2);
    
  l1 = 101.5;
  l2 = 10;
  l3 = 7.5;
    
  l21 = 44;

difference() {
        union(){
                cylinder(h=l21 - (l2 + l3), r1=do1 / 2, r2=do1 / 2 , $fn=360);
                translate([0,0, l21 - (l2 + l3)])
                cylinder(h=l2, r1=do1 / 2, r2=do2 / 2, $fn=360);
                translate([0,0, l21 - (l2 + l3) + l2])
                cylinder(h=l3, r1=do2 /2, r2=do2 / 2, $fn=360);
                
            translate([42,0, 0])  
                rotate([0, -90, 0])
                union(){
                    translate([0,0, l2 + l3])
                        cylinder(h=l1, r1=do1 / 2, r2=do1 / 2, $fn=360);
                    translate([0,0, l3])
                        cylinder(h=l2, r1=do2 / 2, r2=do1 / 2, $fn=360);
                    cylinder(h=l3, r1=do2 /2, r2=do2 / 2, $fn=360);
                };
        };
        
        union(){
            translate([0,0, l2 + l3])
                cylinder(h=l1 + 1, r1=di1 / 2, r2=di1 / 2, $fn=360);
            translate([0,0, l3 - 1])
                cylinder(h=l2 + 2, r1=di2 / 2, r2=di1 / 2, $fn=360);
            translate([0,0, -1])
                cylinder(h=l3 + 2, r1=di2 /2, r2=di2 / 2, $fn=360);
            
            translate([42,0, 0])
                rotate([0, -90, 0])
                    union(){
                        translate([0,0, l2 + l3])
                            cylinder(h=l1 + 1, r1=di1 / 2, r2=di1 / 2, $fn=360);
                        translate([0,0, l3 - 1])
                            cylinder(h=l2 + 2, r1=di2 / 2, r2=di1 / 2, $fn=360);
                        translate([0,0, -1])
                            cylinder(h=l3 + 2, r1=di2 /2, r2=di2 / 2, $fn=360);
                    };
        };

    }; 
};