mode = "holder";  // holder, holder_split, drawer_parts

module holder_model() {
    import("desk_shelf_holder.stl");
}

module holder_split_model() {
    import("desk_shelf_holder_base.stl");
    translate([165, 0, 0])
        import("desk_shelf_holder_cap.stl");
}

module drawer_parts_model() {
    import("drawer_table_rail.stl");

    translate([0, 45, 0])
        rotate([90, 0, 0])
            import("drawer_box_runner.stl");
}

if (mode == "holder") {
    holder_model();
} else if (mode == "holder_split") {
    holder_split_model();
} else if (mode == "drawer_parts") {
    drawer_parts_model();
}