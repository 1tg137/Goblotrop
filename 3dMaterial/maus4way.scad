use <../libs/piCam/files/RPiCam-v2.scad>
use <../libs/rpi/files/raspberrypi.scad>

$fn=40;
// x ist laenge
// y ist tiefe
// z ist hoehe
//Also die "kleinen "Mauskäfige haben Maße von angeblich 268 mm Länge, 215mm Tiefe und 141 mm Höhe. Dies gilt für die Grundfläche, nach oben hin erweitern sich die Käfige etwas.  Ich selbst habe gemessen ca 250 mm (für die Länge oben) 220 mm (für die Länge unten),  und 200  mm für die Tiefe oben und 190 mm für die Tiefe unten 135 mm Höh

//small variante
kaefigLaengeOben=250.0;
kaefigLaengeUnten=220.0;
kaefigTiefeOben=215.0;
kaefigTiefeUnten=170.0;
kaefigHoehe=135;
kameraAbstand=2.0;

raspiSpace=40;
grundplatteLaenge=kaefigLaengeUnten+raspiSpace;
grundplatteTiefe=kaefigTiefeUnten+raspiSpace;
grundplatteHoehe=4;
camHoehe=kaefigHoehe;
camPcbXs = 25.0;
camPcbYs = 23.85;

//--------- DRILL PARAMETERS
drillPlateDicke = 5;
drillDurchmesser = 3;

camDistanceK=100;
camDistanceL=150;



module triangle(length,width)
{
    difference(){
        cube([length,length,width]);
        rotate([0,0,45]) cube([2*length,2*length,width]);
    }
}
module stelze(hoehe=3,durchmesser=6)
{
	innenDurchmesser=2;
	stelzenHoehe=hoehe;
		cylinder(d=durchmesser,h=stelzenHoehe,center=true);
}
module RPiStelzen(center,a,b,c,d,durchmesser=6)
{
	x=58;
	y=49;

	if(center==true){
					translate([-x/2,-y/2 ]) stelze(a,durchmesser);
					translate([-x/2,-y/2 ]) translate([x,0,0 ]) stelze(b,durchmesser); 
					translate([-x/2,-y/2 ]) translate([0,y,0 ]) stelze(c,durchmesser); 
					translate([-x/2,-y/2]) translate([x,y,0 ]) stelze(d,durchmesser); 
	}else{
					stelze(a,durchmesser);
					translate([x,0,0 ]) stelze(b,durchmesser); 
					translate([0,y,0 ]) stelze(c,durchmesser); 
					translate([x,y,0 ]) stelze(d,durchmesser); 
	}
}
module kaefig()
{
	kL = kaefigLaengeUnten;
	kT = kaefigTiefeUnten;
	kH = kaefigHoehe;
difference(){	
	color("green",0.5)	cube([kL,kT,kH]);
		translate([1,1,1]) cube([kL-2,kT-2,kH]);
	}
}
module grundplatte()
{

	difference(){	
		cube([grundplatteLaenge,grundplatteTiefe,grundplatteHoehe]);
		translate([raspiSpace/2,raspiSpace/2,0 ] ) cube([grundplatteLaenge-raspiSpace,grundplatteTiefe-raspiSpace,grundplatteHoehe]);
	}
}

//cube([20,30,kaefigHoehe]);

hoehe=kaefigHoehe;
chSizeX = 40;
chSizeY = 3;
chSizeZ = 2*kaefigHoehe/3;
module camStelzen(center=false,a=3,b=3,c=3,d=3)
{
	x=12.5;
	y=20.8;
	dm=3.5;
	if(center==true){
					translate([-x/2,-y/2 ]) stelze(a,dm);
					translate([-x/2,-y/2 ]) translate([x,0,0 ]) stelze(b,dm); 
					translate([-x/2,-y/2 ]) translate([0,y,0 ]) stelze(c,dm); 
					translate([-x/2,-y/2]) translate([x,y,0 ]) stelze(d,dm); 
	}else{
	translate([2,2,0 ]){
					 stelze(a,dm);
					 translate([x,0,0 ]) stelze(b,dm); 
					 translate([0,y,0 ]) stelze(c,dm); 
					 translate([x,y,0 ]) stelze(d,dm); 
		}
	}
}

module bodenplatteSeitenwand(x,y,z,off=0,showDrills)
{
difference(){
		cube([x,y,z]);
	//translate([x/2,y/2,z]) rotate([0,0,90])	cylinder(d=drillDurchmesser,h=2*z,center=true);
}

translate([0,off,0 ])
difference(){
		translate([0,0,16 ]) rotate([0,90,0 ]) triangle(length=16,width=x);	
	//translate([x/2,y/2,z]) rotate([0,0,90])	cylinder(d=drillDurchmesser,h=2*z,center=true);
}

	if(showDrills==1){
	//	translate([x/2,y/2,z]) rotate([0,0,90])	cylinder(d=drillDurchmesser,h=10*z,center=true);
//		translate([x/2,y/2,z]) rotate([0,0,90])	cylinder(d=drillDurchmesser,h=10*z,center=true);
	}

}


module camHolder(showDrills,stegLaenge,showSteg)
{
sm=1.0; 
camHoleX=13;
camHoleY=19;
	difference(){
		cube([chSizeX,chSizeY,chSizeZ]);
		translate([ (chSizeX - camHoleX*sm )/2,-2,kaefigHoehe/2 ]) rotate([90,180,180 ]) scale(v=[sm,sm,sm ]) cube([camHoleX,camHoleY,10]);  //cam_full();
	translate([(chSizeX - camPcbXs*sm)/2,1,kaefigHoehe/2 ]) rotate([90,90,0 ]) camStelzen(a=5,b=5,c=5,d=5);
		translate([chSizeX/2,0,0 ]) rotate([0,0,90]) steg(laenge=stegLaenge,showDrills=0,showSteg=1);
	}
	if(showSteg==1){
		translate([chSizeX/2,0,0 ]) rotate([0,0,90]) steg(laenge=stegLaenge,showDrills=0,showSteg=1);
	}
	
	difference(){
	translate([0,0,0 ]) 	bodenplatteSeitenwand(chSizeX,20,drillPlateDicke,0,showDrills);
 translate([chSizeX/2,0,0]) rotate([0,0,90]) steg(laenge=150,showDrills=0);	
		translate([chSizeX/2,0,0 ]) rotate([0,0,90]) steg(laenge=stegLaenge,showDrills=1,showSteg=1);
	}
	if(showDrills){
		translate([chSizeX/2,0,0 ]) rotate([0,0,90]) steg(laenge=stegLaenge,showDrills=1,showSteg=1);
	}
}
module rpiHolder(showDrills)
{
		rhSizeX = 75;
		rhSizeY = 3;
		rhSizeZ = 2*kaefigHoehe/3+5;

module modStelzen(){
		cube([rhSizeX,rhSizeY,rhSizeZ]);
	translate([45,-2,45 ]) rotate([ 90, 0 ,180 ]) translate([10,15,0 ]) RPiStelzen(center=true,a=3,b=3,c=3,d=3);
}

difference(){
	modStelzen();
	translate([45,-2,45 ]) rotate([ 90, 0 ,180 ])
	{
		translate([10,15,-1 ]) RPiStelzen(center=true,a=12,b=0,c=0,d=12);
//		rotate([0,180,0 ])pi3();
	}
	}
	//cube([rhSizeX,20,drillPlateDicke ]);
translate([0,-3,0 ])	bodenplatteSeitenwand(rhSizeX,23,drillPlateDicke,3,showDrills);
}
module rpiHolder2(showDrills)
{
		rhSizeX = 80;
		rhSizeY = 70;
		rhSizeZ = 4;

	difference(){
		cube([rhSizeX,rhSizeY,rhSizeZ]);
		translate([10,10,2 ]) RPiStelzen(a=5,b=5,c=5,d=5,durchmesser=4);
	}
		translate([10,10,3 ]) RPiStelzen(a=0,b=6,c=6,d=0,durchmesser=5);
//		translate([10,10,3 ]) RPiStelzen(a=0,b=3,c=3,d=0,durchmesser=6);
}
module seitenWand(center,showDrills,stegLaenge,showSteg)
{
	if(center==true){

	translate([-chSizeX/2,0,0 ]){
		camHolder(showDrills,stegLaenge,showSteg);
//		translate([chSizeX,0,0 ]) rpiHolder2(showDrills);
		
		}
	
	}else{

		camHolder(showDrills,stegLaenge);
//		translate([chSizeX,0,0 ]) rpiHolder2(showDrills);
	//	cube([10,10,0]);


	}



}

module steg(laenge=0,showDrills=0,showSteg=1)
{

	x=laenge+15;
	y=30;
	z=3;
	drillDiameter=3;
	
//	if(showSteg==1){
//		translate([x/2,0,z/2 ]) cube([x,y,z],center=true);
//	}



	if(showDrills==1){	
	if(showSteg==1){
		translate([x/2,0,z/2 ]) cube([x,y,z],center=true);
	}
		//Seite der Seitenwand
		translate([7,y/3,-5]) cylinder(h=40,d=drillDiameter);
		translate([7,-y/3,-5]) cylinder(h=40,d=drillDiameter);
		//Rahmen
		translate([x-7,y/3,-5]) cylinder(h=40,d=drillDiameter);
		translate([x-7,-y/3,-5]) cylinder(h=40,d=drillDiameter);
		

	}else{
		if(showSteg==1){
		difference(){
		translate([x/2,0,z/2 ]) cube([x,y,z],center=true);
//		translate([x/2,0,z/2 ]) cube([x,y,z],center=true);
		//Seite der Seitenwand
		translate([7,y/3,-5]) cylinder(h=40,d=drillDiameter);
		translate([7,-y/3,-5]) cylinder(h=40,d=drillDiameter);

		//Rahmen
		translate([x-7,y/3,-5]) cylinder(h=40,d=drillDiameter);
		translate([x-7,-y/3,-5]) cylinder(h=40,d=drillDiameter);
		}
	}

	}

}


kaefigMitteL = grundplatteLaenge/2 ; 
kaefigMitteT = grundplatteTiefe/2 ; 

//rpiHolder();
//seitenWand(center=true);
//translate([diffL/2,diffT/2,0]) kaefig();
module mouse4wayFull()
{
		grundplatte();
		translate([kaefigMitteL,-camDistanceL,0 ]) seitenWand(center=true,stegLaenge=camDistanceL,showSteg=1,showDrills=0);
		translate([grundplatteLaenge+camDistanceK,kaefigMitteT,0 ]) rotate([0,0,90 ]) seitenWand(center=true,stegLaenge=camDistanceK,showSteg=1,showDrills=0);
		translate([kaefigMitteL,grundplatteTiefe+camDistanceL,0 ]) rotate([0,0,180 ]) seitenWand(center=true,stegLaenge=camDistanceL,showSteg=1,showDrills=0);
		translate([-camDistanceK,kaefigMitteT,0 ]) rotate([0,0,270 ]) seitenWand(center=true,stegLaenge=camDistanceK,showSteg=1,showDrills=0);
}
module mouse4wayHalf()
{
		grundplatte();
		translate([kaefigMitteL,-camDistanceL,0 ]) seitenWand(center=true,stegLaenge=camDistanceL,showSteg=1,showDrills=0);
		translate([grundplatteLaenge+camDistanceK,kaefigMitteT,0 ]) rotate([0,0,90 ]) seitenWand(center=true,stegLaenge=camDistanceK,showSteg=1,showDrills=0);
	//	translate([kaefigMitteL,grundplatteTiefe+camDistanceL,0 ]) rotate([0,0,180 ]) seitenWand(center=true,stegLaenge=camDistanceL,showSteg=1,showDrills=0);
	//	translate([-camDistanceK,kaefigMitteT,0 ]) rotate([0,0,270 ]) seitenWand(center=true,stegLaenge=camDistanceK,showSteg=1,showDrills=0);
}

module grundplatteWDrills()
{
difference(){
		grundplatte();
		translate([kaefigMitteL,-camDistanceL,0 ]) seitenWand(center=true,stegLaenge=camDistanceL,showSteg=1,showDrills=1);
		translate([grundplatteLaenge+camDistanceK,kaefigMitteT,0 ]) rotate([0,0,90 ]) seitenWand(center=true,stegLaenge=camDistanceK,showSteg=1,showDrills=1);
		translate([kaefigMitteL,grundplatteTiefe+camDistanceL,0 ]) rotate([0,0,180 ]) seitenWand(center=true,stegLaenge=camDistanceL,showSteg=1,showDrills=1);

		translate([-camDistanceK,kaefigMitteT,0 ]) rotate([0,0,270 ]) seitenWand(center=true,stegLaenge=camDistanceK,showSteg=1,showDrills=1);
	}

}

stelzeHoehe=224;
stelzeBreite=20;
stelzeTiefe=20;
stelzeGrundplatteHoehe=4;
stelzeGrundplatteBreite=stelzeBreite+30;
stelzeGrundplatteTiefe=stelzeTiefe+30;

leisteBreite=14;
leisteLaenge=250;
leisteDicke=6;

stelzePlattformWandBreite=3;
stelzePlattformWandHoehe=4;
stelzePlattformHoehe=6;
stelzePlattformBreite=leisteBreite+2*stelzePlattformWandBreite;
stelzePlattformTiefe=leisteBreite+ 2*stelzePlattformWandBreite;

stelzeHoeheAuflage=stelzeHoehe;
module tower(center=false)
{
	// grundplatte
	sgh = stelzeGrundplatteHoehe;
	sgb=stelzeGrundplatteBreite;
	sgt=stelzeGrundplatteTiefe;
	cube([ sgt ,sgb ,sgh ],center=true);

	sh=stelzeHoehe;
	st=stelzeTiefe;
	sb=stelzeBreite;

	//stelze
	difference(){
	translate([0,0,sh/2 ]) cube([st,sb,sh],center=true);
	translate([0,0,sh ]) cylinder(center=true,d=2.5,h=5);
	}
	//plattform oben

	spwb = stelzePlattformWandBreite;
	spwh = stelzePlattformWandHoehe;
	translate([sb/2 - spwb/2 + 0.25 ,0,sh ]) cube([spwb-0.5,st,4 ],center=true);
	translate([-sb/2 + spwb/2 - 0.25 ,0,sh ]) cube([spwb-0.5,st,4 ],center=true);
//	translate([0,-st/2+spwb/2,sh ]) cube([st,spwb,4 ],center=true);
}

anzahlLedsProLeiste=5;
ledPlatteDicke=1.5;
ledLochGross=8;
ledLoch=4.9;
abstandLeds= (leisteLaenge/2 - leisteBreite/2 -stelzeBreite/2)/anzahlLedsProLeiste; 
module leiste()
{
	difference(){
		cube([leisteBreite,leisteLaenge,leisteDicke ],center=true);	
//		translate([0,leisteLaenge/2 - stelzePlattformWandBreite,0 ]) cylinder(d=3,h=leisteDicke,center=true);

		for(i=[0:3]){
			translate([0,leisteLaenge/2-3-i*kreuzDifferenzSchrauben,0]) cylinder(d=3,h=leisteDicke,center=true); 
		}
		for(i=[0:3]){
			translate([0,-leisteLaenge/2+3+i*kreuzDifferenzSchrauben,0]) cylinder(d=3,h=leisteDicke,center=true); 
		}
	//grosse Loecher
		for( i = [0 : anzahlLedsProLeiste-1 ] ){
			translate([ 0, i * abstandLeds, ledPlatteDicke ])	cylinder(h=leisteDicke,d=ledLochGross,center=true);
			translate([ 0, -i * abstandLeds,ledPlatteDicke ])	cylinder(h=leisteDicke,d=ledLochGross,center=true);
		}

	//kleine Loecher
		for( i = [0 : anzahlLedsProLeiste-1 ] ){
			translate([ 0, i * abstandLeds, 0 ])	cylinder(h=leisteDicke,d=ledLoch,center=true);
			translate([ 0, -i * abstandLeds,0 ])	cylinder(h=leisteDicke,d=ledLoch,center=true);
		}
	}
}


module kreuzVerschraubung()
{

		for( i = [0:3]){
			for( j = [0:3]){
			rotate([0,0,i*90 ])	translate([kreuzLeisteLaenge/2-3-j*kreuzDifferenzSchrauben,0,0]) cylinder(d=3.5,h=leisteDicke,center=true); 
			}
		}	
}

kreuzLeisteLaenge=4*leisteBreite;
kreuzBreite=leisteBreite;
kreuzDifferenzSchrauben=6;
module leisteKreuz()
{

	difference(){
		cube([kreuzBreite,kreuzLeisteLaenge,3],center=true);
		kreuzVerschraubung();
		cylinder(d=4.9,h=3,center=true);
	}
	difference(){
		cube([kreuzLeisteLaenge,kreuzBreite,3],center=true);
		kreuzVerschraubung();
		cylinder(d=4.9,h=3,center=true);
	}
}

//leisteKreuz();
//leiste();

//tower();
//translate([0,leisteLaenge/2,stelzeHoeheAuflage ]) leiste();
//translate([0,leisteLaenge,0]) rotate([0,0,180]) stelze();

// leiste();
//translate([20,0,0 ]) topLeiste();
//kaefig();
/*
grundplatteWDrills();

translate([40,40,0 ]) steg(laenge=camDistanceK,showDrills=0,showSteg=1);
translate([40,80,0 ]) steg(laenge=camDistanceK,showDrills=0,showSteg=1);
translate([40,120,0 ]) steg(laenge=camDistanceL,showDrills=0,showSteg=1);
translate([40,160,0 ]) steg(laenge=camDistanceL,showDrills=0,showSteg=1);
*/
//seitenWand(center=true,stegLaenge=150,showSteg=0,showDrills=0);
//translate([40,0,0]) rotate([0,0,90])  steg(laenge=150,showDrills=1,showSteg=1);
//rpiHolder2();
//camHolder();
mouse4wayHalf();
//steg(laenge=camDistanceK,showDrills=1,showSteg=0);
//translate([0,30,0 ]) steg(laenge=camDistanceK,showDrills=0);
