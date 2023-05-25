
R = 45;
Rr = 6.5; //disc roller radius: 695zz 5x13x4
rollerThickness = 4; // 695zz 
N = 10; // 10 rollers
E = 2; // ethenicity
Sr = 12; // shaft rollor radius: 6802ZZ 15x24x5
discThickness = 5;


module cycloidal_disc(R,
                      Rr,
                      N,
                      E,
                      Sr,
                      Thickness,
                      opd_offs = 5,
                      $fn=360*2) {
    assert(2*E < Rr,"E must be less than Rr/2");
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

    //shaft roller bearing hole
    circle(r = E+Sr);
    
    //output rollor holes 
    for(i = [0:(5)]){
        angle = i*(360/6);
        rotate([0,0,180])translate([(R+opd_offs)*cos(angle)/2,(R+opd_offs)*sin(angle)/2,0]) 
        circle(r = E+Rr);
        }
    }
}
//draw disc roller

rotate([0,0,90]){ 
    for(i = [0:N-1]){
        angle = i*(360/N);

        color([1,0,1])translate([R*cos(angle),R*sin(angle),-discThickness/2-1])linear_extrude(height = rollerThickness,center = true)circle(r = Rr);
    }
    for(i = [0:N-1]){
        angle = i*(360/N);
        color([1,0,1])translate([R*cos(angle),R*sin(angle),discThickness/2+1])linear_extrude(height = rollerThickness,center = true)circle(r = Rr);

    }
    //draw disc
    translate([-E,0,-discThickness/2-1]) rotate([0,0,180]) cycloidal_disc(R=R,Rr=Rr,E=E,N=N,Sr=Sr,Thickness=discThickness);
    color([1,1,1])translate([E,0,discThickness/2+1])cycloidal_disc(R=R,Rr=Rr,E=E,N=N,Sr=Sr,Thickness=discThickness);

}
