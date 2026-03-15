board_length = 1200;
board_depth = 200;
board_thickness = 18;
top_of_board_height = 120;

support_height = top_of_board_height - board_thickness;

holder_depth = 145;
holder_width = 58;
base_thickness = 10;
side_wall_thickness = 6;
top_platform_depth = 110;
top_platform_thickness = 10;
retainer_height = 4;
retainer_thickness = 4;
center_rib_thickness = 6;
union_overlap = 0.4;

cutout_margin = 16;
cutout_bottom = 18;
cutout_top_offset = 14;

split_z = 56;
joint_overlap_height = 12;
joint_block_x = 16;
joint_block_y = 18;
joint_clearance = 0.35;

add_screw_holes = true;
screw_hole_diameter = 4.5;
screw_head_diameter = 8;
screw_head_height = 2.5;
screw_length = top_platform_thickness + board_thickness - 2;

render_part = "base";  // "base", "cap", "holder"
show_preview = false;
show_full_table = true;
show_preview_screws = true;
explode_parts = false;
explode_distance = 25;

$fn = 48;

top_platform_x = (holder_depth - top_platform_depth) / 2;
holder_total_height = support_height + retainer_height;
joint_x_positions = [holder_depth / 2 - 22, holder_depth / 2 + 22];

echo("Holder print size (mm):", [holder_depth, holder_width, holder_total_height]);
echo("Shelf underside height (mm):", support_height);
echo("Split part heights (mm):", [split_z, holder_total_height - split_z + joint_overlap_height]);

module side_profile() {
    difference() {
        polygon(points = [
            [0, 0],
            [holder_depth, 0],
            [holder_depth, base_thickness],
            [top_platform_x + top_platform_depth, support_height - top_platform_thickness],
            [top_platform_x + top_platform_depth, support_height],
            [top_platform_x, support_height],
            [top_platform_x, support_height - top_platform_thickness],
            [0, base_thickness]
        ]);

        polygon(points = [
            [cutout_margin, base_thickness + cutout_bottom],
            [holder_depth - cutout_margin, base_thickness + cutout_bottom],
            [holder_depth / 2 + 20, support_height - top_platform_thickness - cutout_top_offset],
            [holder_depth / 2 - 20, support_height - top_platform_thickness - cutout_top_offset]
        ]);
    }
}

module support_shell() {
    union() {
        cube([holder_depth, holder_width, base_thickness]);

        translate([0, side_wall_thickness, 0])
            rotate([90, 0, 0])
                linear_extrude(height = side_wall_thickness)
                    side_profile();

        translate([0, holder_width, 0])
            rotate([90, 0, 0])
                linear_extrude(height = side_wall_thickness)
                    side_profile();

        translate([top_platform_x, 0, support_height - top_platform_thickness - union_overlap])
            difference() {
                cube([
                    top_platform_depth,
                    holder_width,
                    top_platform_thickness + retainer_height + union_overlap
                ]);

                translate([retainer_thickness, -0.1, top_platform_thickness + union_overlap])
                    cube([
                        top_platform_depth - (retainer_thickness * 2),
                        holder_width + 0.2,
                        retainer_height + 1
                    ]);
            }

        translate([(holder_depth - center_rib_thickness) / 2, 0, base_thickness - union_overlap])
            cube([
                center_rib_thickness,
                holder_width,
                support_height - top_platform_thickness - base_thickness + (union_overlap * 2)
            ]);
    }
}

module shelf_screw_holes() {
    for (x_pos = joint_x_positions) {
        translate([x_pos, holder_width / 2, support_height - top_platform_thickness - 1])
            cylinder(h = top_platform_thickness + retainer_height + 2, d = screw_hole_diameter);
    }
}

module holder_body() {
    if (add_screw_holes) {
        difference() {
            support_shell();
            shelf_screw_holes();
        }
    } else {
        support_shell();
    }
}

module lower_mask() {
    translate([-1, -1, -1])
        cube([holder_depth + 2, holder_width + 2, split_z + 1]);
}

module upper_mask() {
    translate([-1, -1, split_z])
        cube([holder_depth + 2, holder_width + 2, holder_total_height - split_z + 2]);
}

module joint_block(x_pos, clearance = 0) {
    translate([
        x_pos - (joint_block_x / 2) - clearance,
        (holder_width - joint_block_y) / 2 - clearance,
        split_z - joint_overlap_height - clearance
    ])
        cube([
            joint_block_x + (clearance * 2),
            joint_block_y + (clearance * 2),
            joint_overlap_height + clearance
        ]);
}

module base_joint_pockets() {
    for (x_pos = joint_x_positions) {
        joint_block(x_pos, joint_clearance);
    }
}

module base_joint_holes() {
    children();
}

module cap_joint_blocks() {
    for (x_pos = joint_x_positions) {
        joint_block(x_pos);
    }
}

module cap_joint_thread_holes() {
    children();
}

module base_part_actual() {
    difference() {
        intersection() {
            holder_body();
            lower_mask();
        }

        base_joint_pockets();
    }
}

module cap_part_actual() {
    difference() {
        union() {
            intersection() {
                holder_body();
                upper_mask();
            }

            cap_joint_blocks();
        }
    }
}

module base_part_print() {
    base_part_actual();
}

module cap_part_print() {
    translate([0, 0, -(split_z - joint_overlap_height)])
        cap_part_actual();
}

module screw_visual(length, shaft_diameter, head_diameter, head_height) {
    color([0.75, 0.77, 0.8]) {
        cylinder(h = length, d = shaft_diameter);

        translate([0, 0, length])
            cylinder(h = head_height, d1 = head_diameter, d2 = shaft_diameter + 0.5);
    }
}

module preview_board_screws(y_offset = 0) {
    for (x_pos = joint_x_positions) {
        translate([x_pos, y_offset + holder_width / 2, support_height - top_platform_thickness])
            screw_visual(screw_length, screw_hole_diameter - 0.6, screw_head_diameter, screw_head_height);
    }
}

module preview_joint_screws(y_offset = 0) {
    children();
}

module assembled_holder(y_offset = 0) {
    color([0.2, 0.25, 0.3])
        translate([0, y_offset, 0])
            base_part_actual();

    color([0.25, 0.3, 0.35])
        translate([0, y_offset, explode_parts ? explode_distance : 0])
            cap_part_actual();

    if (show_preview_screws) {
        preview_board_screws(y_offset);
    }

}

module preview() {
    color([0.85, 0.85, 0.9])
        translate([0, 0, support_height])
            cube([
                board_depth,
                show_full_table ? board_length : holder_width,
                board_thickness
            ]);

    assembled_holder();

    if (show_full_table) {
        assembled_holder(board_length - holder_width);
    }
}

module full_holder_print() {
    holder_body();
}

if (show_preview) {
    preview();
} else if (render_part == "cap") {
    cap_part_print();
} else if (render_part == "holder") {
    full_holder_print();
} else {
    base_part_print();
}