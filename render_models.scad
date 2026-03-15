mode = "holder";  // holder, drawer_parts, full_setup

board_length = 1200;
board_depth = 200;
board_thickness = 18;
board_bottom_z = 102;

holder_span_y = board_length - 58;

drawer_box_width = 220;
drawer_box_depth = 150;
drawer_box_height = 70;

drawer_box_y = (board_length - drawer_box_width) / 2;
drawer_box_x = board_depth - drawer_box_depth;
drawer_box_bottom_z = 18;

table_rail_left_y = 473;
table_rail_right_y = 699;
table_rail_top_z = board_bottom_z;

runner_left_y = 484;
runner_right_y = 710;
runner_bottom_z = drawer_box_bottom_z + 8;

module holder_model() {
    import("desk_shelf_holder.stl");
}

module drawer_parts_model() {
    import("drawer_table_rail.stl");

    translate([0, 55, 0])
        translate([0, 0, 160])
            rotate([0, 90, 0])
                import("drawer_box_runner.stl");
}

module full_setup_model() {
    color([0.85, 0.85, 0.9])
        translate([0, 0, board_bottom_z])
            cube([board_depth, board_length, board_thickness]);

    color([0.2, 0.25, 0.3]) {
        import("desk_shelf_holder.stl");

        translate([0, holder_span_y, 0])
            import("desk_shelf_holder.stl");
    }

    color([0.22, 0.27, 0.33]) {
        translate([0, table_rail_left_y + 28, table_rail_top_z])
            rotate([180, 0, 0])
                import("drawer_table_rail.stl");

        translate([0, table_rail_right_y + 28, table_rail_top_z])
            rotate([180, 0, 0])
                import("drawer_table_rail.stl");
    }

    color([0.3, 0.35, 0.4]) {
        translate([0, runner_left_y, runner_bottom_z])
            rotate([0, 90, 0])
                import("drawer_box_runner.stl");

        translate([0, runner_right_y, runner_bottom_z])
            rotate([0, 90, 0])
                import("drawer_box_runner.stl");
    }

    color([0.72, 0.58, 0.42])
        translate([drawer_box_x, drawer_box_y, drawer_box_bottom_z])
            cube([drawer_box_depth, drawer_box_width, drawer_box_height]);
}

if (mode == "holder") {
    holder_model();
} else if (mode == "drawer_parts") {
    drawer_parts_model();
} else if (mode == "full_setup") {
    full_setup_model();
}