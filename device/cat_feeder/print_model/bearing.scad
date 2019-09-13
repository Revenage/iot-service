module bearing() {
    do = 10;
    di = 3;
    w = 4;
    difference() {
        cylinder(h=w, d = do, $fn=40);
        cylinder(h=w + 2, d = di, $fn=40);
    }
}