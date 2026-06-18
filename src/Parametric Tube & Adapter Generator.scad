$fa = $preview ? 8 : 2;
$fs = $preview ? 2 : 0.5;

//$fn = $preview ? 64 : 144;

Diameter_Mode_A = "outer"; // [outer:Außenmaß, inner:Innenmaß]
A_Diameter = 30; //[5:0.1:300.0]

Diameter_Mode_B = "outer"; // [outer:Außenmaß, inner:Innenmaß]
B_Diamenter = 20; //[5:0.1:300.0]

A_Hight = 10; //[5:0.1:100.0]
B_Hight = 10; //[5:0.1:100.0]

Transition_typ = "angle"; // [angle:Angle, per_height:Transition_Height_manual]

Transition_Height_manual = 20; //[25:0.1:100]
Angle = 30; //[5:0.1:45.0]

Fase = 0.2; //[0.0:0.1:1.0]
Wall_Thikness = 1.6; // [0.8:0.1:5]

/* [Hidden] */
tiny_epsilon = 0.01;

//######################################################
//############# Inner & Outer Diameter #################
//######################################################

// A-Seite
outer_dA =
    Diameter_Mode_A == "inner"
    ? A_Diameter + 2 * Wall_Thikness
    : A_Diameter;

inner_dA =
    Diameter_Mode_A == "inner"
    ? A_Diameter
    : A_Diameter - 2 * Wall_Thikness;


// B-Seite
outer_dB =
    Diameter_Mode_B == "inner"
    ? B_Diamenter + 2 * Wall_Thikness
    : B_Diamenter;

inner_dB =
    Diameter_Mode_B == "inner"
    ? B_Diamenter
    : B_Diamenter - 2 * Wall_Thikness;


// Sicherheitsprüfungen
assert(outer_dA > inner_dA, "Fehler A: Außendurchmesser muss größer als Innendurchmesser sein!");
assert(outer_dB > inner_dB, "Fehler B: Außendurchmesser muss größer als Innendurchmesser sein!");
assert(inner_dA > 0, "Fehler A: Innendurchmesser ist kleiner oder gleich 0!");
assert(inner_dB > 0, "Fehler B: Innendurchmesser ist kleiner oder gleich 0!");


//######################################################
//#################### Module ##########################
//######################################################

module adapter_base(
    hoehe1,
    hoehe2,
    durchmesser1,
    durchmesser2,
    transition_typ,
    angle,
    transition_height_manual,
    fase
){

    assert(durchmesser1 > 0 && durchmesser2 > 0, "Durchmesser müssen größer 0 sein!");
    assert(durchmesser1 != durchmesser2, "Beide Durchmesser dürfen nicht gleich sein!");
    assert(angle > 4 && angle < 89, "Angle muss zwischen 4 und 89 Grad liegen!");
    assert(transition_height_manual > 0, "Transition height muss größer 0 sein!");

    radius_diff = abs(durchmesser1 - durchmesser2) / 2;

    transition_height =
        transition_typ == "angle"
        ? radius_diff / tan(angle)
        : transition_height_manual;

    union(){

        cylinder(
            h = hoehe1 + tiny_epsilon * 2,
            d1 = durchmesser1 + fase,
            d2 = durchmesser1
        );

        translate([0, 0, hoehe1 + tiny_epsilon])
            cylinder(
                h = transition_height,
                d1 = durchmesser1,
                d2 = durchmesser2
            );

        translate([0, 0, hoehe1 + transition_height])
            cylinder(
                h = hoehe2,
                d1 = durchmesser2,
                d2 = durchmesser2 - fase
            );
    }
}


//######################################################
//#################### Ausgabe #########################
//######################################################

difference(){

    // Außenkörper
    adapter_base(
        A_Hight,
        B_Hight,
        outer_dA,
        outer_dB,
        Transition_typ,
        Angle,
        Transition_Height_manual,
        Fase
    );

    // Innenausschnitt
    translate([0, 0, -tiny_epsilon])
        adapter_base(
            A_Hight,
            B_Hight + tiny_epsilon * 2,
            inner_dA,
            inner_dB,
            Transition_typ,
            Angle,
            Transition_Height_manual,
            0
        );
}