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

var fruit: Food = undefined;
var snake: [SNAKE_LENGTH]Snake = undefined;
var snake_position: [SNAKE_LENGTH]rl.Vector2 = undefined;
var allow_move: bool = false;
var offset = rl.Vector2.init(0, 0);

var counter_tail: u32 = 0;

fn init_game() void {
    frames_counter = 0;
    game_over = false;
    pause = false;

    counter_tail = 1;
    allow_move = false;

    offset.x = SCREEN_WIDTH % SQUARE_SIZE;
    offset.y = SCREEN_HEIGHT % SQUARE_SIZE;

    var i: u32 = 0;
    while (i < SNAKE_LENGTH) : (i += 1) {
        snake[i].position = rl.Vector2.init(offset.x / 2, offset.y / 2);
        snake[i].size = rl.Vector2.init(SQUARE_SIZE, SQUARE_SIZE);
        snake[i].speed = rl.Vector2.init(SQUARE_SIZE, 0);
        snake[i].color = if (i == 0) rl.Color.dark_blue else rl.Color.blue;
    }

    i = 0;
    while (i < SNAKE_LENGTH) : (i += 1) {
        snake_position[i] = rl.Vector2.init(0.0, 0.0);
    }

    fruit.size = rl.Vector2.init(SQUARE_SIZE, SQUARE_SIZE);
    fruit.color = rl.Color.sky_blue;
    fruit.active = false;
}

fn update_game() void {
    if (!game_over) {
        if (rl.isKeyPressed(rl.KeyboardKey.key_p)) pause = !pause;
        if (!pause) {
            if (rl.isKeyPressed(rl.KeyboardKey.key_right) and (snake[0].speed.x == 0) and allow_move) {
                snake[0].speed = rl.Vector2.init(SQUARE_SIZE, 0);
                allow_move = false;
            }
            if (rl.isKeyPressed(rl.KeyboardKey.key_left) and (snake[0].speed.x == 0) and allow_move) {
                snake[0].speed = rl.Vector2.init(-SQUARE_SIZE, 0);
                allow_move = false;
            }
            if (rl.isKeyPressed(rl.KeyboardKey.key_up) and (snake[0].speed.y == 0) and allow_move) {
                snake[0].speed = rl.Vector2.init(0, -SQUARE_SIZE);
                allow_move = false;
            }
            if (rl.isKeyPressed(rl.KeyboardKey.key_down) and (snake[0].speed.y == 0) and allow_move) {
                snake[0].speed = rl.Vector2.init(0, SQUARE_SIZE);
                allow_move = false;
            }

            var j: u32 = 0;
            while (j < counter_tail) : (j += 1) {
                snake_position[j] = snake[j].position;
            }

            if (@mod(frames_counter, 5) == 0) {
                var i: u32 = 0;
                while (i < counter_tail) : (i += 1) {
                    if (i == 0) {
                        snake[0].position.x += snake[0].speed.x;
                        snake[0].position.y += snake[0].speed.y;
                        allow_move = true;
                    } else {
                        snake[i].position = snake_position[i - 1];
                    }
                }
            }
            if ((snake[0].position.x > (SCREEN_WIDTH - offset.x)) or
                (snake[0].position.y > (SCREEN_HEIGHT - offset.y)) or
                (snake[0].position.x < 0) or (snake[0].position.y < 0))
            {
                game_over = true;
            }

            var k: u32 = 0;
            while (k < counter_tail) : (k += 1) {
                if ((snake[0].position.x == snake[k].position.x) and (snake[0].position.y == snake[k].position.y)) {
                    game_over = true;
                }
            }
            if (!fruit.active) {
                fruit.active = true;

                var fx: i32 = rl.getRandomValue(0, (SCREEN_WIDTH / SQUARE_SIZE) - 1) * @as(i32, @intFromFloat(SQUARE_SIZE + offset.x / 2));
                var fy: i32 = rl.getRandomValue(0, (SCREEN_WIDTH / SQUARE_SIZE) - 1) * @as(i32, @intFromFloat(SQUARE_SIZE + offset.y / 2));

                fruit.position = rl.Vector2.init(@as(f32, @floatFromInt(fx)), @as(f32, @floatFromInt(fy)));

                var i: u32 = 0;
                while (i < counter_tail) : (i += 1) {
                    while ((fruit.position.x == snake[i].position.x) and (fruit.position.y == snake[i].position.y)) {
                        fx = rl.getRandomValue(0, (SCREEN_WIDTH / SQUARE_SIZE) - 1) * @as(i32, @intFromFloat(SQUARE_SIZE + offset.x / 2));
                        fy = rl.getRandomValue(0, (SCREEN_WIDTH / SQUARE_SIZE) - 1) * @as(i32, @intFromFloat(SQUARE_SIZE + offset.y / 2));

                        fruit.position = rl.Vector2.init(@as(f32, @floatFromInt(fx)), @as(f32, @floatFromInt(fy)));

                        i = 0;
                    }
                }
            }
        }
        const pause_text = if (pause) "PAUSED" else "RESUMED";
        rl.drawText(pause_text, 10, 10, 32, rl.Color.yellow);

        if ((snake[0].position.x < (fruit.position.x + fruit.size.x) and (snake[0].position.x + snake[0].size.x) > fruit.position.x) and
            (snake[0].position.y < (fruit.position.y + fruit.size.y) and (snake[0].position.y + snake[0].size.y) > fruit.position.y))
        {
            snake[counter_tail].position = snake_position[counter_tail - 1];
            counter_tail += 1;
            fruit.active = false;
        }

        frames_counter += 1;
    } else {
        if (rl.isKeyPressed(rl.KeyboardKey.key_enter)) {
            init_game();
            game_over = false;
        }
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
