fov_arc = 90; // Field of view angle (degrees)
ray_count = 36; // Number of rays to cast
max_distance = 500; // Maximum ray distance (pixels)
surface = -1; // Initialize surface

// Define vertex format for position and color (with alpha)
vertex_format_begin();
vertex_format_add_position(); // 2D position (x, y)
vertex_format_add_color(); // Color and alpha
vformat = vertex_format_end();

// Create vertex buffer
vbuffer = vertex_create_buffer();
if (vbuffer == -1) {
    show_debug_message("Failed to create vertex buffer!");
}

shadow_length = 150; // Length of shadow extension (pixels)

// Animation variables
image_speed = 0.2; // Animation speed (adjust for smoothness, 0.1-0.3 works well)
