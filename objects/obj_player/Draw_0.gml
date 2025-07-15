// Create a surface to draw on based on the size of the room
if (!surface_exists(surface)) {
    surface = surface_create(room_width, room_height);
}
surface_set_target(surface);
draw_clear_alpha(c_black, 0); // Clear surface to transparent

// Start vertex buffer for light cone and shadows
vertex_begin(vbuffer, vformat);

// Cast rays in a cone
var player_x = x; // Player's x position
var player_y = y; // Player's y position
var angle_step = fov_arc / ray_count; // Angle between rays
var start_angle = point_direction(x, y, mouse_x, mouse_y) - fov_arc / 2; // Center cone on mouse

var ray_points = array_create(ray_count + 1); // Store ray endpoints
for (var i = 0; i <= ray_count; i++) {
    var angle = start_angle + i * angle_step;
    var ray_x = player_x + lengthdir_x(max_distance, angle);
    var ray_y = player_y + lengthdir_y(max_distance, angle);
    
    // Check collision along the line
    var hit = collision_line(player_x, player_y, ray_x, ray_y, obj_wall, false, true);
    var dist = max_distance;
    if (hit != noone) {
        ray_x = hit.x;
        ray_y = hit.y;
        dist = point_distance(player_x, player_y, ray_x, ray_y);
    }
    
    // Store ray endpoint
    ray_points[i] = { x: ray_x, y: ray_y, dist: dist };
}

// Draw light cone with fading
for (var i = 0; i < array_length(ray_points) - 1; i++) {
    var curr = ray_points[i];
    var next = ray_points[i + 1];
    
    // Calculate alpha based on distance (1 at player, 0 at max_distance)
    var curr_alpha = 1 - (curr.dist / max_distance);
    var next_alpha = 1 - (next.dist / max_distance);
    curr_alpha = clamp(curr_alpha, 0, 1);
    next_alpha = clamp(next_alpha, 0, 1);
    
    // Add triangle to vertex buffer for light
    vertex_position(vbuffer, player_x, player_y);
    vertex_color(vbuffer, c_white, 1); // Opaque at player
    vertex_position(vbuffer, curr.x, curr.y);
    vertex_color(vbuffer, c_white, curr_alpha);
    vertex_position(vbuffer, next.x, next.y);
    vertex_color(vbuffer, c_white, next_alpha);
}

// Cast shadow rays and draw shadow regions
for (var i = 0; i < array_length(ray_points) - 1; i++) {
    var curr = ray_points[i];
    var next = ray_points[i + 1];
    
    // Find the wall instance at current ray endpoint
    var wall = collision_point(curr.x, curr.y, obj_wall, false, true);
    if (wall != noone) {
        // Direction away from light source (opposite of ray direction)
        var ray_dir = point_direction(player_x, player_y, curr.x, curr.y);
        var shadow_dir = (ray_dir + 180) mod 360; // Opposite direction
        
        // Extend shadow ray
        var shadow_x = curr.x + lengthdir_x(shadow_length, shadow_dir);
        var shadow_y = curr.y + lengthdir_y(shadow_length, shadow_dir);
        
        // Calculate shadow fade (darker near wall, fading to overlay alpha)
        var dist_to_shadow = point_distance(curr.x, curr.y, shadow_x, shadow_y);
        var shadow_alpha = 1 - (dist_to_shadow / shadow_length); // 1 at wall, 0 at end
        shadow_alpha = clamp(shadow_alpha, 0, 0.8); // Fade to overlay alpha (0.8)
        
        // Add shadow triangle
        vertex_position(vbuffer, curr.x, curr.y);
        vertex_color(vbuffer, c_black, 1); // Fully dark at wall
        vertex_position(vbuffer, next.x, next.y);
        vertex_color(vbuffer, c_black, 1); // Fully dark at next point
        vertex_position(vbuffer, shadow_x, shadow_y);
        vertex_color(vbuffer, c_black, shadow_alpha); // Fade to overlay alpha
    }
}

// End and draw vertex buffer
vertex_end(vbuffer);
vertex_submit(vbuffer, pr_trianglelist, -1);

// Reset surface and draw it to the screen
surface_reset_target();
draw_set_color(c_black);
draw_set_alpha(0.8); // Dark overlay
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(1); // Reset alpha
draw_surface(surface, 0, 0); // Draw the surface

// Draw FPS on screen
draw_set_color(c_white); // Set text color to white
draw_set_alpha(1); // Ensure text is fully opaque
draw_text(10, 10, "FPS: " + string(fps)); // Draw FPS at top-left (x=10, y=10)
draw_set_alpha(1); // Reset alpha (though already 1)

// Draw the player sprite
draw_self(); // Ensure player sprite is drawn