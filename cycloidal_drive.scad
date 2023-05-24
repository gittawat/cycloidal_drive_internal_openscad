module cycloidal_disc(R=45,
                      Rr=6.5,
                      N=16,
                      E=1.5,
                      Sr=8,
                      Thickness=5,
                      $fn=360*2) {
    angles = [for(i = [0:$fn-1]) i*(360/$fn)];
    function psi_t(theta) = -atan(sin((1-N)*theta)/((R/(E*N)) - cos((1-N)*theta)));
    function x_coord(theta) = R*cos(theta)-Rr*cos(theta-psi_t(theta))-E*cos(N*theta); 
    function y_coord(theta) = -R*sin(theta)+Rr*sin(theta-psi_t(theta))+E*sin(N*theta);
    //coords = [for(t=angles) [(R*cos(t))-(Rr*cos(t+atan(sin((1-N)*t)/((R/(E*N))-cos((1-N)*t)))))-(E*cos(N*t)),
    //                         (-R*sin(t))+(Rr*sin(t+atan(sin((1-N)*t)/((R/(E*N))-cos((1-N)*t)))))+(E*sin(N*t))]];
    coords = [for(t=angles) [x_coord(t),y_coord(t)]];
    linear_extrude(height = 5,center = true)
    difference(){
    polygon(coords);
    circle(r = E+Sr);
    for(i = [0:(5)]){
        angle = i*(360/6);
        rotate([0,0,180])translate([(R+1)*cos(angle)/2,(R+1)*sin(angle)/2,0]) 
        circle(r= E+Rr);
        }
    }
}
translate([-1.5,0,-5/2-1]) rotate([0,0,180]) cycloidal_disc();
#translate([1.5,0,5/2+1]) cycloidal_disc();

