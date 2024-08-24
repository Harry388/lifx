pub fn stringEquals(one: []const u8, two: []const u8) bool {
    if (one.len != two.len) return false;
    for (one, two) |one_c, two_c| {
        if (one_c != two_c) return false;
    }
    return true;
}
