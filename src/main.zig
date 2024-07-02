// raylib-zig (c) Nikolas Wipper 2023

const rl = @import("raylib");
const std = @import("std");
const SNAKE_LENGTH = 256;
const SQUARE_SIZE = 31;

const Snake = struct {
    position: rl.Vector2,
    size: rl.Vector2,
    speed: rl.Vector2,
    color: rl.Color,
};

const Food = struct {
    position: rl.Vector2,
    size: rl.Vector2,
    active: bool,
    color: rl.Color,
};

const SCREEN_WIDTH = 800;
const SCREEN_HEIGHT = 450;

var frames_counter: i32 = 0;
var game_over: bool = false;
var pause: bool = false;

var fruit = Food{};
var snake: [SNAKE_LENGTH]Snake = undefined;
var snake_position: [SNAKE_LENGTH]rl.Vector2 = undefined;
var allow_move: bool = false;
var offset = rl.Vector2{};

var counter_tail: i32 = 0;

fn update_game() void {
    if (!game_over) {
        if (rl.isKeyPressed(rl.KeyboardKey.key_p)) pause = !pause;
        if (!pause) {}
        const pause_text = if (pause) "PAUSED" else "RESUMED";
        rl.drawText(pause_text, 10, 10, 32, rl.Color.yellow);
    }
}

fn draw_game() void {}

fn update_draw_frame() void {
    update_game();
    draw_game();
}

pub fn main() anyerror!void {
    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Class gmae: snake");
    defer rl.closeWindow();

    // Main game loop
    rl.setTargetFPS(60);
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);
        update_draw_frame();
    }
}
