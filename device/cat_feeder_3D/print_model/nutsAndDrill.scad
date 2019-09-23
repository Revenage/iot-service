
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