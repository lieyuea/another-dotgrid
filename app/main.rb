def init
  return unless $state.tick_count.zero?

  # $gtk.set_window_fullscreen

  $default_keybinds = {
    fullscreen: 'p',
    # save_state: 'o',
  }
  $keybinds ||= $default_keybinds

  $scroll_bar = {
    x: 1270,
    y: 50,
    max_y: 600,
    min_y: 50,
    w: 9,
    h: 50,
    primitive_marker: :solid
  }
  scroll_bar_border = {
    x: $scroll_bar.x,
    y: $scroll_bar.min_y,
    w: $scroll_bar.w,
    h: $scroll_bar.max_y,
    primitive_marker: :border
  }

  $points = []
  60.times do |x|
    30.times do |y|
      $points << { x: 50 + 20 * x, y: 650 - 20 * y, w: 2, h: 2, primitive_marker: :solid }
    end
  end

  $outputs.static_primitives << [ $scroll_bar, scroll_bar_border, $points ]
end

def calc
  mouse = $inputs.mouse

  if mouse.wheel
    $scroll_bar.y += mouse.wheel.y * $scroll_bar.h
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
    { x: 0, y: 720, text: "mouse coord: #{$inputs.mouse.x}, #{$inputs.mouse.y}" },
    # $layout.debug_primitives
  ]
end

$gtk.reset
