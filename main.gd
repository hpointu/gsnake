extends Node

const W = 40
const H = 30
const SIZE = 10
enum {UP, LEFT, DOWN, RIGHT}

var speed
var label = Label.new()
var score_label = Label.new()
var snake = Snake.new(Vector2(10, 10), 3)

class Snake extends Node2D:
    var dead = true
    var cells = []
    var food
    var dir = RIGHT
    var t = 0
    var score = 0
    var speed = 10

    func _init(pos, size):
        spawn_food()
        for i in range(size):
            cells.push_front(pos + Vector2(i, 0))

    func spawn_food():
        food = Vector2(randi() % W, randi() % H)
        if touches(food):
            return spawn_food()
        return food

    func suicide():
        var body = cells.duplicate()
        var head = body.pop_front()
        for c in body:
            if head == c:
                return true
        return false

    func touches(pos):
        for c in cells:
            if pos == c:
                return true
        return false

    func out(pos):
        return pos.x < 0 or pos.y < 0 or pos.x >= W or pos.y >= H

    func step():
        if dead:
            return
        var d
        match dir:
            UP:
                d = Vector2(0, -1)
            RIGHT:
                d = Vector2(1, 0)
            DOWN:
                d = Vector2(0, 1)
            LEFT:
                d = Vector2(-1, 0)

        var head = cells.front()
        var new = head + d
        if new == food:
            spawn_food()
            cells.push_back(food)
            speed += 1
            score += speed * 10
        elif out(new) or suicide():
            dead = true
        if not dead:
            cells.push_front(new)
            cells.pop_back()
        update()

    func _process(delta):
        if Input.is_action_pressed("ui_up"):
            if dir != DOWN: dir = UP
        if Input.is_action_pressed("ui_left"):
            if dir != RIGHT: dir = LEFT
        if Input.is_action_pressed("ui_down"):
            if dir != UP: dir = DOWN
        if Input.is_action_pressed("ui_right"):
            if dir != LEFT: dir = RIGHT

        t += delta
        if t > 1.0/speed:
            t = 0
            step()

    func _draw():
        draw_rect(Rect2(0, 0, W * SIZE, H * SIZE),
                    Color(1, 1, 1), false)
        draw_rect(Rect2(food.x * SIZE, food.y * SIZE, SIZE-1, SIZE-1),
                    Color(1, 0, 0))
        for cell in cells:
            draw_rect(Rect2(cell.x * SIZE, cell.y * SIZE, SIZE-1, SIZE-1),
                         Color(0, 1, 0))

func _ready():
    label.text = "Click to start"
    label.rect_position = Vector2(W*SIZE/2 - 30, H*SIZE/2)
    label.add_color_override("font_color", Color(1,0,0))
    label.visible = true
    add_child(label)
    score_label.rect_position = Vector2(10, H*SIZE + 20)

func init_snake():
    snake = Snake.new(Vector2(10, 10), 3)
    snake.position = Vector2(10, 10)
    snake.dead = false
    add_child(snake)
    add_child(score_label)

func _input(event):
    if snake.dead and event is InputEventMouseButton:
        label.text = "Game Over!\nEnter or click to restart"
        remove_child(snake)
        remove_child(score_label)
        init_snake()

func _process(delta):
    label.visible = snake.dead
    score_label.text = "Score: %s" % snake.score
