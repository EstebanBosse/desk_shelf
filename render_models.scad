mode = "holder";  // holder, drawer_parts, full_setup

board_length = 1200;

holder_span_y = board_length - 58;

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
        translate([0, 1200, 120])
            rotate([180, 0, 0])
                import("drawer_slide_assembly_preview.stl");

    color([0.2, 0.25, 0.3]) {
        import("desk_shelf_holder.stl");

        translate([0, holder_span_y, 0])
            import("desk_shelf_holder.stl");
    }
}

if (mode == "holder") {
    holder_model();
} else if (mode == "drawer_parts") {
    drawer_parts_model();
} else if (mode == "full_setup") {
    full_setup_model();
}