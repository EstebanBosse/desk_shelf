shelf_length = 1200;
shelf_depth = 200;
shelf_thickness = 18;

box_width = 220;
box_depth = 150;
box_height = 70;

slide_length = 160;
union_overlap = 0.4;

table_rail_width = 28;
table_mount_thickness = 6;
table_slot_outer_width = 20;
table_slot_depth = 10;
table_slot_head_width = 15;
table_slot_opening_width = 8;
rear_stop_thickness = 5;
front_entry_length = 8;

runner_mount_thickness = 6;
runner_mount_height = 36;
runner_head_width = 14.4;
runner_head_height = 5.5;
runner_neck_width = 7.4;
runner_neck_height = 4.5;
runner_clearance = 0.55;
front_detent_length = 10;
front_detent_height = 1.8;
front_detent_offset = 12;

add_mount_holes = true;
table_mount_hole_diameter = 4.5;
table_mount_head_diameter = 8.5;
table_mount_head_depth = 2.8;
box_mount_hole_diameter = 4.0;

render_part = "table";  // "table", "box", "assembly"
show_preview = false;
show_box = true;

$fn = 48;

table_slot_y = (table_rail_width - table_slot_outer_width) / 2;
table_slot_head_y = (table_rail_width - table_slot_head_width) / 2;
table_slot_open_y = (table_rail_width - table_slot_opening_width) / 2;
runner_head_y = (runner_mount_thickness - runner_head_width) / 2;
runner_neck_y = (runner_mount_thickness - runner_neck_width) / 2;

table_mount_hole_positions = [18, slide_length / 2, slide_length - 18];
box_mount_hole_positions = [18, slide_length / 2, slide_length - 18];

box_y = (shelf_length - box_width) / 2;
box_x = shelf_depth - box_depth;
left_runner_y = box_y - runner_mount_thickness;
right_runner_y = box_y + box_width;
left_table_y = left_runner_y - ((table_rail_width - runner_mount_thickness) / 2);
right_table_y = right_runner_y - ((table_rail_width - runner_mount_thickness) / 2);

echo("Table rail print size (mm):", [slide_length, table_rail_width, table_mount_thickness + table_slot_depth]);
echo("Box runner print size (mm):", [slide_length, runner_mount_height, runner_head_width]);
echo("Runner clearance (mm):", runner_clearance);
echo("Mount hole positions (mm):", table_mount_hole_positions);

module table_mount_holes() {
    for (x_pos = table_mount_hole_positions) {
        translate([x_pos, table_rail_width / 2, -0.1])
            cylinder(h = table_mount_thickness + 0.2, d = table_mount_hole_diameter);

        translate([x_pos, table_rail_width / 2, table_mount_thickness - table_mount_head_depth])
            cylinder(h = table_mount_head_depth + 0.2, d1 = table_mount_head_diameter, d2 = table_mount_hole_diameter + 0.6);
    }
}

module table_rail_installed() {
    difference() {
        union() {
            cube([slide_length, table_rail_width, table_mount_thickness]);

            translate([0, table_slot_y, table_mount_thickness - union_overlap])
                cube([slide_length, table_slot_outer_width, table_slot_depth + union_overlap]);

            translate([slide_length - rear_stop_thickness, table_slot_y, table_mount_thickness + table_slot_depth - 2 - union_overlap])
                cube([rear_stop_thickness, table_slot_outer_width, 2 + union_overlap]);

            translate([
                front_detent_offset,
                table_slot_head_y,
                table_mount_thickness + table_slot_depth - runner_neck_height - front_detent_height
            ])
                cube([front_detent_length, table_slot_head_width, front_detent_height]);
        }

        translate([-0.1, table_slot_head_y, table_mount_thickness])
            cube([
                slide_length - rear_stop_thickness + 0.2,
                table_slot_head_width,
                table_slot_depth - runner_neck_height + 0.1
            ]);

        translate([-0.1, table_slot_open_y, table_mount_thickness + table_slot_depth - runner_neck_height - 0.1])
            cube([slide_length + 0.2, table_slot_opening_width, runner_neck_height + 0.2]);

        translate([-0.1, table_slot_head_y, table_mount_thickness - 0.1])
            cube([
                front_entry_length + 0.2,
                table_slot_head_width,
                table_slot_depth + 0.2
            ]);

        if (add_mount_holes) {
            table_mount_holes();
        }
    }
}

module box_mount_holes() {
    for (x_pos = box_mount_hole_positions) {
        translate([x_pos, -0.1, runner_mount_height / 2])
            rotate([-90, 0, 0])
                cylinder(h = runner_mount_thickness + 0.2, d = box_mount_hole_diameter);
    }
}

module box_runner_installed() {
    difference() {
        union() {
            translate([0, 0, table_mount_thickness + table_slot_depth - union_overlap])
                cube([slide_length, runner_mount_thickness, runner_mount_height + union_overlap]);

            translate([0, runner_head_y, table_mount_thickness + table_slot_depth - runner_neck_height - runner_head_height + runner_clearance])
                cube([slide_length, runner_head_width, runner_head_height]);

            translate([0, runner_neck_y, table_mount_thickness + table_slot_depth - runner_neck_height - union_overlap + runner_clearance])
                cube([slide_length, runner_neck_width, runner_neck_height + union_overlap]);
        }

        if (add_mount_holes) {
            box_mount_holes();
        }
    }
}

module table_rail_print() {
    table_rail_installed();
}

module box_runner_print() {
    rotate([0, -90, 0])
        translate([0, 0, -slide_length])
            box_runner_installed();
}

module box_preview() {
    color([0.72, 0.58, 0.42])
        translate([box_x, box_y, table_mount_thickness + table_slot_depth + runner_mount_height])
            cube([box_depth, box_width, box_height]);
}

module assembly_preview() {
    color([0.84, 0.84, 0.88])
        cube([shelf_depth, shelf_length, shelf_thickness]);

    color([0.2, 0.25, 0.3]) {
        translate([0, left_table_y, shelf_thickness])
            table_rail_installed();

        translate([0, right_table_y, shelf_thickness])
            table_rail_installed();
    }

    color([0.28, 0.33, 0.38]) {
        translate([0, left_runner_y, shelf_thickness])
            box_runner_installed();

        translate([0, right_runner_y, shelf_thickness])
            box_runner_installed();
    }

    if (show_box) {
        box_preview();
    }
}

if (show_preview || render_part == "assembly") {
    assembly_preview();
} else if (render_part == "box") {
    box_runner_print();
} else {
    table_rail_print();
}