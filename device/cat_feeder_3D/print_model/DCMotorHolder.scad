
fn = 64;

module dcMotor() {
    
    cylinder(h=59, d=2.3, $fn=fn);
    
    translate([0, 0, 0.5])
    cylinder(h=51.7, d=10, $fn=fn);
    
    translate([0, 0, 2])
    cylinder(h=47, d=27.7, $fn=fn);
    
    
}

module button() {
    translate([-3.2, 16, 0])
    import("/Users/user378/Downloads/products/8720/stl/8720.STL");
    
}

dcMotor();

button();