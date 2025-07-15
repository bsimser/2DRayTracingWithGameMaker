// This lets you move the player with arrow keys or WASD
var move_speed = 4; // Speed in pixels per step
var h_move = (keyboard_check(vk_right) || keyboard_check(ord("D"))) - (keyboard_check(vk_left) || keyboard_check(ord("A"))); // Horizontal input
var v_move = (keyboard_check(vk_down) || keyboard_check(ord("S"))) - (keyboard_check(vk_up) || keyboard_check(ord("W"))); // Vertical input

// Check horizontal collision
if (!place_meeting(x + h_move * move_speed, y, obj_wall)) {
    x += h_move * move_speed;
}
// Check vertical collision
if (!place_meeting(x, y + v_move * move_speed, obj_wall)) {
    y += v_move * move_speed;
}

var is_moving = (h_move != 0 || v_move != 0); // Check if moving

// Switch sprite based on movement
if (is_moving) {
    sprite_index = spr_player_run; // Set to walk animation
} else {
    sprite_index = spr_player_idle; // Set to idle animation
}

// Move the player (with or without collisions)
if (!place_meeting(x + h_move * move_speed, y, obj_wall)) {
    x += h_move * move_speed;
}
if (!place_meeting(x, y + v_move * move_speed, obj_wall)) {
    y += v_move * move_speed;
}
