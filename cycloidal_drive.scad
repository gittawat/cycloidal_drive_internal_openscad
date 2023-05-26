

R = 50;              // outper ring pitch radius
Rr = 6.5;            // disc roller radius: 695zz 5x13x4
rollerThickness = 4; // 695zz
N = 16;              // 16 rollers
E = 1.5;             // ethenicity
discThickness = 8;
opd_offs = 8;


isr_outer_r = 16;     // input shaft rollor radius: 6804ZZ 20x32x7
isr_inner_r = 10;
isr_thickness = 7;

osr_outer_r = 26;   // output shaft rollor radius: 6808zz 40x52x7
osr_inner_r = 20;
osr_thickness = 7;


module regular_polygon_rod(redius = 1,h=1,order = 6){
    angles = [for(i = [0:order-1]) i*(360/order)];
    coords = [for (theta=angles) [redius*cos(theta), redius*sin(theta)]];
    linear_extrude(height = h,center = true)polygon(coords);
}

module copy_mirror(vec){
    children();
    mirror(vec)
    children();
}

module cycloidal_disc(R, Rr, N, E, Sr, Thickness, opd_offs, $fn = 360 * 2)
{
    assert(2 * E < Rr, "E must be less than Rr/2");
    angles = [for (i = [0:$fn - 1]) i * (360 / $fn)];
    function psi_t(theta) = -atan(sin((1 - N) * theta) / ((R / (E * N)) - cos((1 - N) * theta)));
    function x_coord(theta) = R * cos(theta) - Rr * cos(theta - psi_t(theta)) - E * cos(N * theta);
    function y_coord(theta) = -R * sin(theta) + Rr * sin(theta - psi_t(theta)) + E * sin(N * theta);
    // coords = [for(t=angles) [(R*cos(t))-(Rr*cos(t+atan(sin((1-N)*t)/((R/(E*N))-cos((1-N)*t)))))-(E*cos(N*t)),
    //                          (-R*sin(t))+(Rr*sin(t+atan(sin((1-N)*t)/((R/(E*N))-cos((1-N)*t)))))+(E*sin(N*t))]];
    coords = [for (t = angles)[x_coord(t), y_coord(t)]];
    linear_extrude(height = Thickness, center = true) difference()
    {
        polygon(coords);

        // shaft roller bearing hole
        circle(r = Sr);

        // output rollor holes
        for (i = [0:(5)])
        {
            angle = i * (360 / 6);
            rotate([ 0, 0, 180 ]) translate([ (R + opd_offs) * cos(angle) / 2, (R + opd_offs) * sin(angle) / 2, 0 ])
                circle(r = E + Rr);
        }
    }
}

rotate([ 0, 0, 0 ])
{
    // draw disc roller
    for (i = [0:N - 1])
    {
        angle = i * (360 / N);
        color([ 1, 1, 1 ])
        {
            translate([ R * cos(angle), R * sin(angle), -discThickness / 2 - 1 ]) difference()
            {
                cylinder(h = rollerThickness, r = Rr, center = true, $fn = 60);
                cylinder(h = rollerThickness + 1, r = 5 / 2, center = true, $fn = 60);
            }
            translate([ R * cos(angle), R * sin(angle), discThickness / 2 + 1 ]) difference()
            {
                cylinder(h = rollerThickness, r = Rr, center = true, $fn = 60);
                cylinder(h = rollerThickness + 1, r = 5 / 2, center = true, $fn = 60);
            }
        }
    }

    // draw output_shaft_roller
    rotate([0,0,-$t*3600/15]){ 
        for (i = [0:60:360])
        {
            angle = i; 
            color([ 1, 0, 0 ])
            {
                translate([ (R+opd_offs) * cos(angle)/2, (R+opd_offs) * sin(angle)/2, -discThickness / 2 - 1 ]) difference()
                {
                    cylinder(h = rollerThickness, r = Rr, center = true, $fn = 60);
                    cylinder(h = rollerThickness + 1, r = 5 / 2, center = true, $fn = 60);
                }
                translate([ (R+opd_offs) * cos(angle)/2, (R+opd_offs) * sin(angle)/2, discThickness / 2 + 1 ]) difference()
                {
                    cylinder(h = rollerThickness, r = Rr, center = true, $fn = 60);
                    cylinder(h = rollerThickness + 1, r = 5 / 2, center = true, $fn = 60);
                }
            }
        }
    }
    // draw disc
    rotate([0,0,$t*3600]){ 
    color([ 0, 1, 0 ]) translate([ -E, 0, -discThickness / 2 - 1 ])rotate([ 0, 0,180-$t*3600-$t*3600/15 ])
        cycloidal_disc(R = R, Rr = Rr, E = E, N = N, Sr = isr_outer_r, Thickness = discThickness,opd_offs=opd_offs);
    color([ 0, 0, 1 ]) translate([ E, 0, discThickness / 2 + 1 ])rotate([ 0, 0, -$t*3600-$t*3600/15 ])
        cycloidal_disc(R = R, Rr = Rr, E = E, N = N, Sr = isr_outer_r, Thickness = discThickness,opd_offs=opd_offs);
    }
    // draw input shaft
    rotate([0,0,$t*3600]){
    difference()
    {
        union()
        {
            
            translate([ E, 0, isr_thickness / 2 + 1 ])
                //cylinder(h = 1, r = isr_inner_r, center = true, $fn = 60);
                union(){
                    translate([0,0,isr_thickness / 2 + 1 -1/2])cylinder(h = 1, r = isr_inner_r+1, center = true, $fn = 60);
                    cylinder(h = isr_thickness, r = isr_inner_r, center = true, $fn = 60);
                    //spacer
                    translate([0,0,-isr_thickness / 2 - 1 +1/2])cylinder(h = 1, r = isr_inner_r+1, center = true, $fn = 60);
                }
        
            translate([ -E, 0, -isr_thickness / 2 - 1 ])
                union(){
                    translate([0,0,-isr_thickness / 2 - 1 +1/2])cylinder(h = 1, r = isr_inner_r+1, center = true, $fn = 60);
                    cylinder(h = isr_thickness, r = isr_inner_r, center = true, $fn = 60);
                    //spacer
                    translate([0,0,isr_thickness / 2 + 1 -1/2])cylinder(h = 1, r = isr_inner_r+1, center = true, $fn = 60);
                }
            // cube([isr_inner_r*2-2*E,isr_inner_r*2,discThickness*2+2],center =true);
            translate([0,0,isr_thickness*1.5 + 3]){
                    cylinder(h = isr_thickness, r = isr_inner_r, center = true, $fn = 60);
                    translate([0,0,-isr_thickness/2-1/2])cylinder(h=1,r=isr_inner_r+1,center=true,$fn=90); 
                } 
            translate([0,0,-isr_thickness*1.5 - 3]){
                    cylinder(h = isr_thickness, r = isr_inner_r, center = true, $fn = 60);
                    translate([0,0,isr_thickness/2+1/2])cylinder(h=1,r=isr_inner_r+1,center=true,$fn=90); 
                } 
        }
        // key hole
        rotate([0,0,90])regular_polygon_rod(isr_inner_r-2*E, h = 4*discThickness + 4*2 + 1);
        }
    }

    //draw output shaft
   // color([0,1,0]) translate([0,0,1+isr_thickness+1+1])difference() {
   //     cylinder(h = isr_thickness , r = isr_outer_r, center = false,$fn = 60);
   //     translate([0,0,-1/2]) cylinder(h = isr_thickness+1, r = isr_inner_r, center = false,$fn=60);
   // }

    rotate([0,0,-$t*3600/15]) 
    #copy_mirror([0,0,1]) color([1,0,1])translate(v = [0,0,1+isr_thickness+1+1]) difference() {
        union(){
        difference() {
            cylinder(h = 4, r = (R+opd_offs)/2 + Rr, center = false,$fn=60);
            translate(v = [0,0,-1/2])cylinder(h = isr_thickness+1, r = isr_outer_r, center = false,$fn=60);
        }
        translate(v = [0,0,4])difference(){
            cylinder(h = isr_thickness-4+2, r = (R+opd_offs)/2 - Rr, center = false);
            translate(v = [0,0,-1/2 -4]) cylinder(h = isr_thickness+1/2, r = isr_outer_r , center = false);
        }
        translate(v = [0,0,isr_thickness+2]){
            cylinder(h = osr_thickness, r = osr_inner_r, center = false);
                
        }
        }
        cylinder(h = isr_thickness+2+(osr_thickness+1), r = isr_outer_r - 3, center = false);
        for (i = [0:6 - 1])
        {
            angle = i * (360 / 6);
            translate([ (R+opd_offs)/2 * cos(angle), (R+opd_offs)/2 * sin(angle),-1]) 
            {
                //cylinder(h = rollerThickness, r = Rr, center = true, $fn = 60);
                cylinder(h = 4 + 2, r = 5 / 2, center=false, $fn = 60);
            }
            #translate(v = [(osr_inner_r + isr_outer_r-3)/2 *cos(angle),(osr_inner_r + isr_outer_r-3)/2 *sin(angle),1+isr_thickness+1]) cylinder(h = osr_thickness+1, r = 4/2, center = false,$fn = 60);
        }
    }
}

