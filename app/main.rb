def init
  return unless $state.tick_count.zero?

  $gtk.set_window_fullscreen

  $default_keybinds = {
    fullscreen: 'p',
    # save_state: 'o',
  }
  $keybinds ||= $default_keybinds

  $scroll_bar = {
    x: $grid.right - 8,
    y: 45,
    max_y: 617,
    min_y: 45,
    w: 7,
    h: 48,
    primitive_marker: :solid
  }
  scroll_bar_border = {
    x: $scroll_bar.x,
    y: 45,
    w: $scroll_bar.w,
    h: 620,
    primitive_marker: :border
  }

  $points = []
  95.times do |x|
    48.times do |y|
      $points << { x: 25 + 13 * x, y: 50 + 13 * y, w: 2, h: 2, primitive_marker: :solid }
    end
  end

  $outputs.static_primitives << [ $scroll_bar, scroll_bar_border, $points ]
end

def calc
  mouse = $inputs.mouse

  if mouse.wheel
    $scroll_bar.y += mouse.wheel.y * 52
    if $scroll_bar.y >= $scroll_bar.max_y
      $scroll_bar.y = $scroll_bar.max_y
    elsif $scroll_bar.y <= $scroll_bar.min_y
      $scroll_bar.y = $scroll_bar.min_y
    end
  end

  if mouse.click
    if mouse.inside_rect? $scroll_bar
      $scroll_bar_held = true
    end
  end

  if mouse.button_left && $scroll_bar_held
    $scroll_bar.y = mouse.y - $scroll_bar.h / 2
    if $scroll_bar.y >= $scroll_bar.max_y
      $scroll_bar.y = $scroll_bar.max_y
    elsif $scroll_bar.y <= $scroll_bar.min_y
      $scroll_bar.y = $scroll_bar.min_y
    end
  else
    $scroll_bar_held = nil
  end

  case $inputs.keyboard.key_down.char
    when $keybinds[:fullscreen] then $gtk.set_window_fullscreen !$gtk.instance_variable_get(:@window_is_fullscreen)
    # when $keybinds[:save_state] then $gtk.save_state
  end
end

def tick args
  init
  calc

  $outputs.debug << [
    {
      x: 0,
      y: 720,
      text: "mouse coord: #{$inputs.mouse.x}, #{$inputs.mouse.y}"
    }, {
      x: 0,
      y: 700,
      text: $scroll_bar
    },
    # $layout.debug_primitives
  ]
end

$gtk.reset
