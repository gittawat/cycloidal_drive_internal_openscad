//drawing circle with for loop

module poly_circle(redius = 1,resolution = 4){
    angles = [for(i = [0:resolution-1]) i*(360/resolution)];
    coords = [for (theta=angles) [redius*cos(theta), redius*sin(theta)]];
    polygon(coords);
}
//translate([0,0,0])poly_circle(resolution = 360,redius = 1);

module epicycloid(r = 1,
                  k = 4,
                  $fn = 4){
    angles = [for(i = [0:$fn-1]) i*(360/$fn)];
    function x_coord(r,k,theta) =(r+k*r)*cos(theta)-r*cos(((k*r+r)/r)*theta);
    function y_coord(r,k,theta) =(r+k*r)*sin(theta)-r*sin(((k*r+r)/r)*theta);
    coords = [for (theta=angles) [x_coord(r,k,theta),y_coord(r,k,theta)]];

    polygon(coords);
}
translate([0,0,-1]) epicycloid($fn=360);
module cycloidal_disc(R=45,
                      Rr=6.5,
                      N=16,
                      E=1.5,
                      $fn=360*2) {
    angles = [for(i = [0:$fn-1]) i*(360/$fn)];
    function psi_t(theta) = -atan(sin((1-N)*theta)/((R/(E*N)) - cos((1-N)*theta)));
    function x_coord(theta) = R*cos(theta)-Rr*cos(theta-psi_t(theta))-E*cos(N*theta); 
    function y_coord(theta) = -R*sin(theta)+Rr*sin(theta-psi_t(theta))+E*sin(N*theta);
    //coords = [for(t=angles) [(R*cos(t))-(Rr*cos(t+atan(sin((1-N)*t)/((R/(E*N))-cos((1-N)*t)))))-(E*cos(N*t)),
    //                         (-R*sin(t))+(Rr*sin(t+atan(sin((1-N)*t)/((R/(E*N))-cos((1-N)*t)))))+(E*sin(N*t))]];
    coords2 = [for(t=angles) [x_coord(t),y_coord(t)]];
    polygon(coords2);
}
cycloidal_disc();
