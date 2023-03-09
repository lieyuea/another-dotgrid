def defaults
  return unless $state.tick_count.zero?

  $gtk.set_window_fullscreen

  $default_keybinds = {
    fullscreen: 'p',
    save_state: 'o',
  }
  $keybinds ||= $default_keybinds

  $scroll_bar = {
    x: $grid.right - 15,
    y: 357,
    max_y: 617,
    min_y: 45,
    w: 14,
    h: 48,
    id: :scroll_bar,
    primitive_marker: :solid
  }
  scroll_area = {
    x: $scroll_bar.x,
    y: 45,
    w: $scroll_bar.w,
    h: 620,
    primitive_marker: :border
  }

  $outputs.static_primitives << [ $scroll_bar, scroll_area, ]
end

def controls
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
      $mouse_held = $scroll_bar
    end
  end

  if mouse.button_left && $mouse_held
    $scroll_bar.y = mouse.y - $scroll_bar.h / 2
    if $scroll_bar.y >= $scroll_bar.max_y
      $scroll_bar.y = $scroll_bar.max_y
    elsif $scroll_bar.y <= $scroll_bar.min_y
      $scroll_bar.y = $scroll_bar.min_y
    end
  else
    $mouse_held = nil
  end

  case $inputs.keyboard.key_down.char
    when $keybinds[:fullscreen] then $gtk.set_window_fullscreen !$gtk.instance_variable_get(:@window_is_fullscreen)
    when $keybinds[:save_state] then $gtk.save_state
  end
end

def tick args
  defaults
  controls

  $outputs.debug << [
    {
      x: 0,
      y: 720,
      text: "mouse coord: #{$inputs.mouse.x}, #{$inputs.mouse.y}"
    }, {
      x: 0,
      y: 700,
      text: "framerate: #{$gtk.current_framerate}"
    }, {
      x: 270,
      y: 720,
      text: "held obj: #{$mouse_held.id}",
    },
    $layout.debug_primitives
  ]
end

$gtk.reset
