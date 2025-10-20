import("/home/theo/unison/3d/maus4way/ledKreuz.stl");
 translate([00,130,5 ]) import("/home/theo/unison/3d/maus4way/ledleiste.stl");
translate([00,-130,5 ]) import("/home/theo/unison/3d/maus4way/ledleiste.stl");
translate([130,0,5 ]) rotate([0,0,90 ]) import("/home/theo/unison/3d/maus4way/ledleiste.stl");
translate([-130,0,5 ]) rotate([0,0,90 ]) import("/home/theo/unison/3d/maus4way/ledleiste.stl");
translate([-15,15,-15 ]) rotate([90,0,45 ]) import("/home/theo/unison/3d/kronleucherToTripod/kronleuchterToTripod.stl");