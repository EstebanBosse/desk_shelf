box_width = 220;
box_height = 70;

handle_width = 120;
handle_height = 30;
plate_thickness = 6;
plate_corner_radius = 2.5;

grip_width = 100;
grip_thickness = 14;
grip_projection = 24;
grip_clearance = 18;

side_support_width = 14;
side_support_depth = grip_projection;
support_blend_radius = 7;

screw_hole_diameter = 4.3;
screw_head_diameter = 8.4;
screw_head_depth = 3.2;
screw_spacing = 84;
add_screw_holes = true;

box_front_thickness = 12;
m4_screw_length = 20;
m4_shaft_diameter = 4.0;
m4_head_diameter = screw_head_diameter;
m4_head_height = 2.5;
show_m4_screws = true;

show_preview = false;

$fn = 48;

echo("Handle print size (mm):", [handle_width, plate_thickness + grip_projection, handle_height]);
echo("Screw spacing (mm):", screw_spacing);
echo("Default fastener:", str("M4 x ", m4_screw_length, " mm countersunk screw"));

module rounded_plate(width, depth, height, radius) {
    linear_extrude(height = height)
        offset(r = radius)
            offset(delta = -radius)
                square([width, depth], center = true);
}

module rounded_bar(length, diameter) {
    rotate([0, 90, 0])
        hull() {
            translate([0, 0, -length / 2 + diameter / 2])
                sphere(d = diameter);
            translate([0, 0, length / 2 - diameter / 2])
                sphere(d = diameter);
        }
}

module m4_countersunk_screw(length) {
    union() {
        cylinder(h = length, d = m4_shaft_diameter);

        translate([0, 0, -m4_head_height])
            cylinder(h = m4_head_height, d1 = m4_head_diameter, d2 = m4_shaft_diameter);
    }
}

module mounting_holes() {
    for (x_pos = [-screw_spacing / 2, screw_spacing / 2]) {
        translate([x_pos, 0, 0]) {
            cylinder(h = plate_thickness + 0.2, d = screw_hole_diameter);

            translate([0, 0, plate_thickness - screw_head_depth])
                cylinder(h = screw_head_depth + 0.2, d1 = screw_hole_diameter + 0.4, d2 = screw_head_diameter);
        }
    }
}

module side_support(x_center) {
    hull() {
        translate([x_center, plate_thickness + support_blend_radius - 0.8, support_blend_radius])
            rotate([0, 90, 0])
                cylinder(h = side_support_width, r = support_blend_radius, center = true);

        translate([x_center, plate_thickness + side_support_depth - (grip_thickness / 2), grip_clearance + (grip_thickness / 2)])
            rotate([0, 90, 0])
                cylinder(h = side_support_width, r = grip_thickness / 2, center = true);
    }
}

module handle_body() {
    difference() {
        union() {
            translate([0, plate_thickness / 2, 0])
                rounded_plate(handle_width, plate_thickness, handle_height, plate_corner_radius);

            for (x_pos = [-grip_width / 2 + side_support_width / 2, grip_width / 2 - side_support_width / 2]) {
                side_support(x_pos);
            }

            translate([0, plate_thickness + grip_projection - (grip_thickness / 2), grip_clearance + (grip_thickness / 2)])
                rounded_bar(grip_width, grip_thickness);
        }

        if (add_screw_holes) {
            translate([0, 0, handle_height / 2])
                rotate([-90, 0, 0])
                    mounting_holes();
        }
    }
}

module preview() {
    color([0.82, 0.69, 0.47])
        translate([-box_width / 2, -box_front_thickness, -box_height / 2])
            cube([box_width, box_front_thickness, box_height]);

    color([0.08, 0.08, 0.08])
        translate([0, 0, -handle_height / 2 + box_height / 2])
            handle_body();

    if (show_m4_screws) {
        color([0.72, 0.74, 0.76])
            translate([0, 0, -handle_height / 2 + box_height / 2])
                for (x_pos = [-screw_spacing / 2, screw_spacing / 2]) {
                    translate([x_pos, 0, handle_height / 2])
                        rotate([-90, 0, 0])
                            m4_countersunk_screw(m4_screw_length);
                }
    }
}

if (show_preview) {
    preview();
} else {
    handle_body();
}