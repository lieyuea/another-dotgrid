def init
  return unless $state.tick_count.zero?

  $gtk.set_window_fullscreen

  $default_keybinds = {
    fullscreen: 'p',
  }
  $keybinds ||= $default_keybinds

  $scroll_bar = {
    x: 1270,
    y: 60,
    max_y: 600,
    min_y: 60,
    w: 9,
    h: 60,
    primitive_marker: :solid
  }
  scroll_bar_border = {
    x: $scroll_bar.x,
    y: $scroll_bar.min_y,
    w: $scroll_bar.w,
    h: $scroll_bar.max_y,
    primitive_marker: :border
  }

  $points     = {}
  point_arr   = []
  $point_rows = []
  $point_cols = []

  60.times do |x|
    $points[x] = {}
    30.times do |y|
      if y % 5 == 0 && x % 5 == 0
        $points[x][y] = { x: 50 + 20 * x, y: 650 - 20 * y, w: 2, h: 2, primitive_marker: :solid }
        point_arr << $points[x][y]
      else
        $points[x][y] = { x: 50 + 20 * x, y: 650 - 20 * y, w: 1, h: 1, primitive_marker: :solid }
        point_arr << $points[x][y]
      end

      next if x > 0
      $point_rows << point_arr.last.y
    end
    $point_cols << point_arr.last.x
  end

  $outputs.static_primitives << [ $scroll_bar, scroll_bar_border, point_arr ]
end

def find_hovered_point mouse
  # iterating rows/cols separately avoids having to iterate 1800 times
  # each frame when hovering over bottom right point
  # since there are less rows than cols, check there first
  in_row = nil
  h = nil
  $point_rows.each_with_index do |coord, row|
    if mouse.inside_rect? [ 0, coord - 10, 1280, 20 ]
      in_row = row
      h = coord
      break
    end
  end

  return unless in_row

  in_col = nil
  $point_cols.each_with_index do |coord, col|
    if mouse.inside_rect? [ coord - 10, h - 10, 20, 20 ]
      in_col = col
      break
    end
  end

  return unless in_col

  $points[in_col][in_row]
end

def mouse_input
  mouse = $inputs.mouse

  hovered_point = find_hovered_point mouse

  if hovered_point
    $hover_border = { x: hovered_point.x - 10, y: hovered_point.y - 10, w: 20, h: 20, primitive_marker: :border }
  else
    $hover_border = nil
  end

  # since the scroll bar is so small, just keep track of if it's held or not
  # instead of dragging inside the bar
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

  ########### TODO: scrolling mouse wheel for zoom
  if mouse.wheel
    $scroll_bar.y += mouse.wheel.y * $scroll_bar.h
    if $scroll_bar.y >= $scroll_bar.max_y
      $scroll_bar.y = $scroll_bar.max_y
    elsif $scroll_bar.y <= $scroll_bar.min_y
      $scroll_bar.y = $scroll_bar.min_y
    end
  end
end

def keyboard_input
  case $inputs.keyboard.key_down.char
    when $keybinds[:fullscreen] then $gtk.set_window_fullscreen !$gtk.instance_variable_get(:@window_is_fullscreen)
  end
end

def calc
  mouse_input
  keyboard_input
end

def draw
  $outputs.primitives << $hover_border
  $outputs.debug << [
    $gtk.framerate_diagnostics_primitives,
    # $layout.debug_primitives
  ]
end

def tick args
  init
  calc
  draw
end

$gtk.reset
