///|
pub struct Padding {
  left : Int
  right : Int
  top : Int
  bottom : Int
}

///|
pub fn padding(all : Int) -> Padding {
  { left: all, right: all, top: all, bottom: all }
}

///|
/// 统一的图表公共参数（Int/Float 共用）。
pub struct ChartOptions {
  width : Int
  height : Int
  padding : Padding
  x_ticks : Int
  y_ticks : Int
  axis_font_size : Int
  show_axes : Bool
  /// Float 轴标签格式：-1 表示沿用默认字符串化（保持当前行为）；>=0 表示固定小数位。
  float_label_precision : Int
}

///|
/// 构造 `ChartOptions`（提供与现有 API 一致的默认值）。
pub fn chart_options(
  width? : Int = 600,
  height? : Int = 200,
  padding? : Padding = padding(20),
  x_ticks? : Int = 5,
  y_ticks? : Int = 5,
  axis_font_size? : Int = 10,
  show_axes? : Bool = true,
  float_label_precision? : Int = -1,
) -> ChartOptions {
  {
    width,
    height,
    padding,
    x_ticks,
    y_ticks,
    axis_font_size,
    show_axes,
    float_label_precision,
  }
}

///|
/// 多折线图参数（在 `ChartOptions` 基础上增加 legend 开关）。
pub struct SeriesChartOptions {
  base : ChartOptions
  show_legend : Bool
}

///|
pub fn series_chart_options(
  base? : ChartOptions = chart_options(),
  show_legend? : Bool = true,
) -> SeriesChartOptions {
  { base, show_legend }
}

///|
pub struct LineSeries {
  data : Array[Int]
  name : String
  stroke : String
  stroke_width : Int
}

///|
pub struct LineSeriesFloat {
  data : Array[Double]
  name : String
  stroke : String
  stroke_width : Int
}

///|
priv struct Layout {
  w : Int
  h : Int
  plot_left : Int
  plot_top : Int
  plot_width : Int
  plot_height : Int
}

///|
fn layout_from_sides(
  width : Int,
  height : Int,
  left : Int,
  right : Int,
  top : Int,
  bottom : Int,
) -> Layout {
  let w = if width <= 1 { 1 } else { width }
  let h = if height <= 1 { 1 } else { height }
  let plot_left = if left < 0 { 0 } else { left }
  let plot_top = if top < 0 { 0 } else { top }
  let plot_width = {
    let v = w - left - right
    if v <= 1 {
      1
    } else {
      v
    }
  }
  let plot_height = {
    let v = h - top - bottom
    if v <= 1 {
      1
    } else {
      v
    }
  }
  { w, h, plot_left, plot_top, plot_width, plot_height }
}

///|
fn layout_from_options(options : ChartOptions) -> Layout {
  let padding = options.padding
  layout_from_sides(
    options.width,
    options.height,
    padding.left,
    padding.right,
    padding.top,
    padding.bottom,
  )
}

///|
fn estimate_text_width(font_size : Int, text : String) -> Int {
  // 粗略估算：平均每个字符约占 0.6em。
  let fs = if font_size < 0 { 0 } else { font_size }
  let n = text.length()
  // (n * fs * 6) / 10
  n * fs * 6 / 10
}

///|
fn max_y_label_width_int(
  minv : Int,
  maxv : Int,
  ticks : Int,
  font_size : Int,
) -> Int {
  let tcount = clamp_ticks(ticks)
  let range = {
    let r = maxv - minv
    if r == 0 {
      1
    } else {
      r
    }
  }
  loop (0, 0) {
    (i, acc) if i >= tcount => acc
    (i, acc) => {
      let v = minv + range * i / (tcount - 1)
      let w = estimate_text_width(font_size, "\{v}")
      let acc2 = if w > acc { w } else { acc }
      continue (i + 1, acc2)
    }
  }
}

///|
fn max_y_label_width_float(
  minv : Double,
  maxv : Double,
  ticks : Int,
  font_size : Int,
  label_precision : Int,
) -> Int {
  let tcount = clamp_ticks(ticks)
  let range = {
    let r = maxv - minv
    if r == 0.0 {
      1.0
    } else {
      r
    }
  }
  loop (0, 0) {
    (i, acc) if i >= tcount => acc
    (i, acc) => {
      let v = minv + range * i.to_double() / (tcount - 1).to_double()
      let s = format_double_label(v, label_precision)
      let w = estimate_text_width(font_size, s)
      let acc2 = if w > acc { w } else { acc }
      continue (i + 1, acc2)
    }
  }
}

///|
fn max_x_label_half_width(n : Int, ticks : Int, font_size : Int) -> Int {
  if n <= 0 {
    0
  } else {
    let denom = if n <= 1 { 0 } else { n - 1 }
    let tcount = {
      let t = clamp_ticks(ticks)
      if denom + 1 <= 0 {
        2
      } else if t > denom + 1 {
        denom + 1
      } else {
        t
      }
    }
    // x 轴标签是索引字符串；最大宽度一般来自最大 idx。
    let max_idx = if tcount <= 0 { denom } else { denom }
    let w = estimate_text_width(font_size, "\{max_idx}")
    (w + 1) / 2
  }
}

///|
fn layout_for_int_axis(
  options : ChartOptions,
  minv : Int,
  maxv : Int,
  x_n : Int,
) -> Layout {
  let padding = options.padding
  if !options.show_axes {
    layout_from_options(options)
  } else {
    let tick_len = 4
    let label_gap = 6
    let y_w = max_y_label_width_int(
      minv,
      maxv,
      options.y_ticks,
      options.axis_font_size,
    )
    let x_half = max_x_label_half_width(
      x_n,
      options.x_ticks,
      options.axis_font_size,
    )
    let left_needed0 = label_gap + y_w + 2
    let left_needed1 = if tick_len > left_needed0 {
      tick_len
    } else {
      left_needed0
    }
    let left_needed2 = if x_half + 2 > left_needed1 {
      x_half + 2
    } else {
      left_needed1
    }
    let left = if padding.left > left_needed2 {
      padding.left
    } else {
      left_needed2
    }
    let right = if padding.right > x_half + 2 {
      padding.right
    } else {
      x_half + 2
    }
    layout_from_sides(
      options.width,
      options.height,
      left,
      right,
      padding.top,
      padding.bottom,
    )
  }
}

///|
fn layout_for_float_axis(
  options : ChartOptions,
  minv : Double,
  maxv : Double,
  x_n : Int,
) -> Layout {
  let padding = options.padding
  if !options.show_axes {
    layout_from_options(options)
  } else {
    let tick_len = 4
    let label_gap = 6
    let y_w = max_y_label_width_float(
      minv,
      maxv,
      options.y_ticks,
      options.axis_font_size,
      options.float_label_precision,
    )
    let x_half = max_x_label_half_width(
      x_n,
      options.x_ticks,
      options.axis_font_size,
    )
    let left_needed0 = label_gap + y_w + 2
    let left_needed1 = if tick_len > left_needed0 {
      tick_len
    } else {
      left_needed0
    }
    let left_needed2 = if x_half + 2 > left_needed1 {
      x_half + 2
    } else {
      left_needed1
    }
    let left = if padding.left > left_needed2 {
      padding.left
    } else {
      left_needed2
    }
    let right = if padding.right > x_half + 2 {
      padding.right
    } else {
      x_half + 2
    }
    layout_from_sides(
      options.width,
      options.height,
      left,
      right,
      padding.top,
      padding.bottom,
    )
  }
}

///|
pub fn line_series(
  data~ : Array[Int],
  name? : String = "",
  stroke? : String = "#3355cc",
  stroke_width? : Int = 2,
) -> LineSeries {
  { data, name, stroke, stroke_width }
}

///|
pub fn line_series_float(
  data~ : Array[Double],
  name? : String = "",
  stroke? : String = "#3355cc",
  stroke_width? : Int = 2,
) -> LineSeriesFloat {
  { data, name, stroke, stroke_width }
}

///|
fn min_max_float(data : Array[Double]) -> (Double, Double) {
  let n = data.length()
  if n == 0 {
    (0.0, 0.0)
  } else {
    loop (1, data[0], data[0]) {
      (i, minv, maxv) if i >= n => (minv, maxv)
      (i, minv, maxv) => {
        let v = data[i]
        let minv2 = if v < minv { v } else { minv }
        let maxv2 = if v > maxv { v } else { maxv }
        continue (i + 1, minv2, maxv2)
      }
    }
  }
}

///|
fn max_len_series_float(series : Array[LineSeriesFloat]) -> Int {
  loop (0, 0) {
    (i, best) if i >= series.length() => best
    (i, best) => {
      let n = series[i].data.length()
      let best2 = if n > best { n } else { best }
      continue (i + 1, best2)
    }
  }
}

///|
fn min_max_series_float(series : Array[LineSeriesFloat]) -> (Double, Double) {
  let n = series.length()
  // 找到第一条非空 series 做初值
  let init = loop 0 {
    i if i >= n => None
    i => {
      let d = series[i].data
      if d.length() == 0 {
        continue i + 1
      } else {
        let (mn, mx) = min_max_float(d)
        Some((mn, mx))
      }
    }
  }
  match init {
    None => (0.0, 0.0)
    Some((mn0, mx0)) =>
      loop (0, mn0, mx0) {
        (i, mn, mx) if i >= n => (mn, mx)
        (i, mn, mx) => {
          let d = series[i].data
          if d.length() == 0 {
            continue (i + 1, mn, mx)
          } else {
            let (a, b) = min_max_float(d)
            let mn2 = if a < mn { a } else { mn }
            let mx2 = if b > mx { b } else { mx }
            continue (i + 1, mn2, mx2)
          }
        }
      }
  }
}

///|
fn min_max_int(data : Array[Int]) -> (Int, Int) {
  let n = data.length()
  if n == 0 {
    (0, 0)
  } else {
    loop (1, data[0], data[0]) {
      (i, minv, maxv) if i >= n => (minv, maxv)
      (i, minv, maxv) => {
        let v = data[i]
        let minv2 = if v < minv { v } else { minv }
        let maxv2 = if v > maxv { v } else { maxv }
        continue (i + 1, minv2, maxv2)
      }
    }
  }
}

///|
fn max_len_series(series : Array[LineSeries]) -> Int {
  loop (0, 0) {
    (i, best) if i >= series.length() => best
    (i, best) => {
      let n = series[i].data.length()
      let best2 = if n > best { n } else { best }
      continue (i + 1, best2)
    }
  }
}

///|
fn min_max_series(series : Array[LineSeries]) -> (Int, Int) {
  let n = series.length()
  // 找到第一条非空 series 做初值
  let init = loop 0 {
    i if i >= n => None
    i => {
      let d = series[i].data
      if d.length() == 0 {
        continue i + 1
      } else {
        let (mn, mx) = min_max_int(d)
        Some((mn, mx))
      }
    }
  }
  match init {
    None => (0, 0)
    Some((mn0, mx0)) =>
      loop (0, mn0, mx0) {
        (i, mn, mx) if i >= n => (mn, mx)
        (i, mn, mx) => {
          let d = series[i].data
          if d.length() == 0 {
            continue (i + 1, mn, mx)
          } else {
            let (a, b) = min_max_int(d)
            let mn2 = if a < mn { a } else { mn }
            let mx2 = if b > mx { b } else { mx }
            continue (i + 1, mn2, mx2)
          }
        }
      }
  }
}

///|
fn svg_doc(contents : @svg.Element, width : Int, height : Int) -> @svg.Element {
  @svg.doc_type() +
  @svg.Element::svg11(contents).with_attr([
    @svg.Version["1.1"],
    @svg.Width["\{width}"],
    @svg.Height["\{height}"],
    @svg.ViewBox["0 0 \{width} \{height}"],
  ])
}

///|
fn axes(
  plot_left : Int,
  plot_top : Int,
  plot_width : Int,
  plot_height : Int,
  stroke : String,
) -> @svg.Element {
  let x0 = plot_left
  let y0 = plot_top
  let x1 = plot_left + plot_width
  let y1 = plot_top + plot_height
  @svg.line([
    @svg.X1["\{x0}"],
    @svg.Y1["\{y1}"],
    @svg.X2["\{x1}"],
    @svg.Y2["\{y1}"],
    @svg.Stroke[stroke],
    @svg.StrokeWidth["1"],
  ]) +
  @svg.line([
    @svg.X1["\{x0}"],
    @svg.Y1["\{y0}"],
    @svg.X2["\{x0}"],
    @svg.Y2["\{y1}"],
    @svg.Stroke[stroke],
    @svg.StrokeWidth["1"],
  ])
}

///|
fn axis_layer_int(
  options : ChartOptions,
  lay : Layout,
  minv : Int,
  maxv : Int,
  x_n : Int,
  axis_color : String,
) -> @svg.Element {
  if options.show_axes {
    axes(
      lay.plot_left,
      lay.plot_top,
      lay.plot_width,
      lay.plot_height,
      axis_color,
    ) +
    y_ticks_and_labels(
      minv,
      maxv,
      lay.plot_left,
      lay.plot_top,
      lay.plot_height,
      options.y_ticks,
      options.axis_font_size,
      axis_color,
      axis_color,
    ) +
    x_ticks_and_labels_indexed(
      x_n,
      lay.plot_left,
      lay.plot_top,
      lay.plot_width,
      lay.plot_height,
      options.x_ticks,
      options.axis_font_size,
      axis_color,
      axis_color,
    )
  } else {
    @svg.g([])
  }
}

///|
fn axis_layer_float(
  options : ChartOptions,
  lay : Layout,
  minv : Double,
  maxv : Double,
  x_n : Int,
  axis_color : String,
) -> @svg.Element {
  if options.show_axes {
    axes(
      lay.plot_left,
      lay.plot_top,
      lay.plot_width,
      lay.plot_height,
      axis_color,
    ) +
    y_ticks_and_labels_float(
      minv,
      maxv,
      lay.plot_left,
      lay.plot_top,
      lay.plot_height,
      options.y_ticks,
      options.axis_font_size,
      axis_color,
      axis_color,
      options.float_label_precision,
    ) +
    x_ticks_and_labels_indexed(
      x_n,
      lay.plot_left,
      lay.plot_top,
      lay.plot_width,
      lay.plot_height,
      options.x_ticks,
      options.axis_font_size,
      axis_color,
      axis_color,
    )
  } else {
    @svg.g([])
  }
}

///|
fn bar_slot_and_width(plot_width : Int, n : Int) -> (Int, Int, Int) {
  let slot = if n == 0 { plot_width } else { plot_width / n }
  let bar_w = {
    let bw = slot * 8 / 10
    if bw <= 1 {
      1
    } else {
      bw
    }
  }
  let x_pad = (slot - bar_w) / 2
  (slot, bar_w, x_pad)
}

///|
fn pow10_int(n : Int) -> Int {
  if n <= 0 {
    1
  } else {
    loop (0, 1) {
      (i, acc) if i >= n => acc
      (i, acc) => continue (i + 1, acc * 10)
    }
  }
}

///|
fn pad_left_zeros_by_width(value : Int, width : Int) -> String {
  if width <= 0 {
    ""
  } else {
    let v = if value < 0 { -value } else { value }
    let len = "\{v}".length()
    let need = width - len
    if need <= 0 {
      ""
    } else {
      loop (0, "") {
        (i, acc) if i >= need => acc
        (i, acc) => continue (i + 1, acc + "0")
      }
    }
  }
}

///|
fn format_double_fixed(v : Double, decimals : Int) -> String {
  let d = if decimals < 0 { 0 } else { decimals }
  let d2 = if d > 12 { 12 } else { d }
  let sign = if v < 0.0 { "-" } else { "" }
  let abs = if v < 0.0 { -v } else { v }
  if d2 == 0 {
    let rounded = (abs + 0.5).to_int()
    "\{sign}\{rounded}"
  } else {
    let scale_i = pow10_int(d2)
    let scaled = abs * scale_i.to_double()
    let scaled_i = (scaled + 0.5).to_int()
    let int_part = scaled_i / scale_i
    let frac = scaled_i % scale_i
    let zeros = pad_left_zeros_by_width(frac, d2)
    "\{sign}\{int_part}.\{zeros}\{frac}"
  }
}

///|
fn format_double_label(v : Double, precision : Int) -> String {
  if precision < 0 {
    "\{v}"
  } else {
    format_double_fixed(v, precision)
  }
}

///|
fn clamp_ticks(ticks : Int) -> Int {
  if ticks < 2 {
    2
  } else {
    ticks
  }
}

///|
fn y_ticks_and_labels(
  minv : Int,
  maxv : Int,
  plot_left : Int,
  plot_top : Int,
  plot_height : Int,
  ticks : Int,
  font_size : Int,
  stroke : String,
  fill : String,
) -> @svg.Element {
  let tcount = clamp_ticks(ticks)
  let range = {
    let r = maxv - minv
    if r == 0 {
      1
    } else {
      r
    }
  }
  let tick_len = 4
  let label_gap = 6
  loop (0, @svg.g([])) {
    (i, acc) if i >= tcount => acc
    (i, acc) => {
      let v = minv + range * i / (tcount - 1)
      let y = plot_top + (maxv - v) * plot_height / range
      let x0 = plot_left
      let x1 = plot_left - tick_len
      let tick = @svg.line([
        @svg.X1["\{x0}"],
        @svg.Y1["\{y}"],
        @svg.X2["\{x1}"],
        @svg.Y2["\{y}"],
        @svg.Stroke[stroke],
        @svg.StrokeWidth["1"],
      ])
      let label = @svg.text(
        [
          @svg.X["\{plot_left - label_gap}"],
          @svg.Y["\{y + (font_size / 3)}"],
          @svg.FontSize["\{font_size}"],
          @svg.TextAnchor["end"],
          @svg.Fill[fill],
        ],
        child=@svg.Element::str("\{v}"),
      )
      continue (i + 1, acc + tick + label)
    }
  }
}

///|
fn y_ticks_and_labels_float(
  minv : Double,
  maxv : Double,
  plot_left : Int,
  plot_top : Int,
  plot_height : Int,
  ticks : Int,
  font_size : Int,
  stroke : String,
  fill : String,
  label_precision : Int,
) -> @svg.Element {
  let tcount = clamp_ticks(ticks)
  let range = {
    let r = maxv - minv
    if r == 0.0 {
      1.0
    } else {
      r
    }
  }
  let tick_len = 4
  let label_gap = 6
  loop (0, @svg.g([])) {
    (i, acc) if i >= tcount => acc
    (i, acc) => {
      let v = minv + range * i.to_double() / (tcount - 1).to_double()
      let y = plot_top.to_double() +
        (maxv - v) * plot_height.to_double() / range
      let x0 = plot_left
      let x1 = plot_left - tick_len
      let tick = @svg.line([
        @svg.X1["\{x0}"],
        @svg.Y1["\{y}"],
        @svg.X2["\{x1}"],
        @svg.Y2["\{y}"],
        @svg.Stroke[stroke],
        @svg.StrokeWidth["1"],
      ])
      let label = @svg.text(
        [
          @svg.X["\{plot_left - label_gap}"],
          @svg.Y["\{y + (font_size / 3).to_double()}"],
          @svg.FontSize["\{font_size}"],
          @svg.TextAnchor["end"],
          @svg.Fill[fill],
        ],
        child=@svg.Element::str(format_double_label(v, label_precision)),
      )
      continue (i + 1, acc + tick + label)
    }
  }
}

///|
fn x_ticks_and_labels_indexed(
  n : Int,
  plot_left : Int,
  plot_top : Int,
  plot_width : Int,
  plot_height : Int,
  ticks : Int,
  font_size : Int,
  stroke : String,
  fill : String,
) -> @svg.Element {
  if n <= 0 {
    @svg.g([])
  } else if n == 1 {
    let x = plot_left
    let y0 = plot_top + plot_height
    let y1 = y0 + 4
    @svg.line([
      @svg.X1["\{x}"],
      @svg.Y1["\{y0}"],
      @svg.X2["\{x}"],
      @svg.Y2["\{y1}"],
      @svg.Stroke[stroke],
      @svg.StrokeWidth["1"],
    ]) +
    @svg.text(
      [
        @svg.X["\{x}"],
        @svg.Y["\{y1 + font_size}"],
        @svg.FontSize["\{font_size}"],
        @svg.TextAnchor["middle"],
        @svg.Fill[fill],
      ],
      child=@svg.Element::str("0"),
    )
  } else {
    let tcount = {
      let t = clamp_ticks(ticks)
      if t > n {
        n
      } else {
        t
      }
    }
    let denom = n - 1
    let tick_len = 4
    loop (0, @svg.g([])) {
      (i, acc) if i >= tcount => acc
      (i, acc) => {
        let idx = i * denom / (tcount - 1)
        let x = plot_left + idx * plot_width / denom
        let y0 = plot_top + plot_height
        let y1 = y0 + tick_len
        let tick = @svg.line([
          @svg.X1["\{x}"],
          @svg.Y1["\{y0}"],
          @svg.X2["\{x}"],
          @svg.Y2["\{y1}"],
          @svg.Stroke[stroke],
          @svg.StrokeWidth["1"],
        ])
        let label = @svg.text(
          [
            @svg.X["\{x}"],
            @svg.Y["\{y1 + font_size}"],
            @svg.FontSize["\{font_size}"],
            @svg.TextAnchor["middle"],
            @svg.Fill[fill],
          ],
          child=@svg.Element::str("\{idx}"),
        )
        continue (i + 1, acc + tick + label)
      }
    }
  }
}

///|
fn line_path_d_scaled(
  data : Array[Int],
  minv : Int,
  maxv : Int,
  x_denom : Int,
  plot_left : Int,
  plot_top : Int,
  plot_width : Int,
  plot_height : Int,
) -> String {
  let n = data.length()
  if n == 0 {
    ""
  } else {
    let range = {
      let r = maxv - minv
      if r == 0 {
        1
      } else {
        r
      }
    }
    let denom = if x_denom <= 0 { 1 } else { x_denom }
    loop (0, "") {
      (i, acc) if i >= n => acc
      (i, acc) => {
        let x = plot_left + i * plot_width / denom
        let y = plot_top + (maxv - data[i]) * plot_height / range
        let seg = if i == 0 { "M \{x},\{y} " } else { "L \{x},\{y} " }
        continue (i + 1, acc + seg)
      }
    }
  }
}

///|
fn line_path_d_scaled_float(
  data : Array[Double],
  minv : Double,
  maxv : Double,
  x_denom : Int,
  plot_left : Int,
  plot_top : Int,
  plot_width : Int,
  plot_height : Int,
) -> String {
  let n = data.length()
  if n == 0 {
    ""
  } else {
    let range = {
      let r = maxv - minv
      if r == 0.0 {
        1.0
      } else {
        r
      }
    }
    let denom = if x_denom <= 0 { 1 } else { x_denom }
    loop (0, "") {
      (i, acc) if i >= n => acc
      (i, acc) => {
        let x = plot_left + i * plot_width / denom
        let y = plot_top.to_double() +
          (maxv - data[i]) * plot_height.to_double() / range
        let seg = if i == 0 { "M \{x},\{y} " } else { "L \{x},\{y} " }
        continue (i + 1, acc + seg)
      }
    }
  }
}

///|
fn legend_layer(
  series : Array[LineSeries],
  plot_left : Int,
  plot_top : Int,
  plot_width : Int,
  font_size : Int,
) -> @svg.Element {
  let x_right = plot_left + plot_width - 2
  let line_len = 14
  let gap = 4
  let row_h = font_size + gap
  loop (0, 0, @svg.g([])) {
    (i, row, acc) if i >= series.length() => {
      let _ = row
      acc
    }
    (i, row, acc) => {
      let s = series[i]
      if s.name == "" {
        continue (i + 1, row, acc)
      } else {
        let y = plot_top + 2 + row * row_h
        let sample = @svg.line([
          @svg.X1["\{x_right - line_len}"],
          @svg.Y1["\{y}"],
          @svg.X2["\{x_right - 2}"],
          @svg.Y2["\{y}"],
          @svg.Stroke[s.stroke],
          @svg.StrokeWidth["\{s.stroke_width}"],
        ])
        let label = @svg.text(
          [
            @svg.X["\{x_right}"],
            @svg.Y["\{y + (font_size / 3)}"],
            @svg.FontSize["\{font_size}"],
            @svg.TextAnchor["end"],
            @svg.Fill["#000"],
          ],
          child=@svg.Element::str(s.name),
        )
        continue (i + 1, row + 1, acc + sample + label)
      }
    }
  }
}

///|
fn legend_layer_float(
  series : Array[LineSeriesFloat],
  plot_left : Int,
  plot_top : Int,
  plot_width : Int,
  font_size : Int,
) -> @svg.Element {
  let x_right = plot_left + plot_width - 2
  let line_len = 14
  let gap = 4
  let row_h = font_size + gap
  loop (0, 0, @svg.g([])) {
    (i, row, acc) if i >= series.length() => {
      let _ = row
      acc
    }
    (i, row, acc) => {
      let s = series[i]
      if s.name == "" {
        continue (i + 1, row, acc)
      } else {
        let y = plot_top + 2 + row * row_h
        let sample = @svg.line([
          @svg.X1["\{x_right - line_len}"],
          @svg.Y1["\{y}"],
          @svg.X2["\{x_right - 2}"],
          @svg.Y2["\{y}"],
          @svg.Stroke[s.stroke],
          @svg.StrokeWidth["\{s.stroke_width}"],
        ])
        let label = @svg.text(
          [
            @svg.X["\{x_right}"],
            @svg.Y["\{y + (font_size / 3)}"],
            @svg.FontSize["\{font_size}"],
            @svg.TextAnchor["end"],
            @svg.Fill["#000"],
          ],
          child=@svg.Element::str(s.name),
        )
        continue (i + 1, row + 1, acc + sample + label)
      }
    }
  }
}

///|
fn bar_legend_layer(
  name : String,
  fill : String,
  stroke : String,
  stroke_width : Int,
  plot_left : Int,
  plot_top : Int,
  plot_width : Int,
  font_size : Int,
) -> @svg.Element {
  if name == "" {
    @svg.g([])
  } else {
    let x_right = plot_left + plot_width - 2
    let sample_w = 14
    let sample_h = {
      let h = font_size * 2 / 3
      if h <= 1 {
        1
      } else {
        h
      }
    }
    let y = plot_top + 2
    let y0 = y - sample_h / 2
    let sample = if stroke == "" {
      @svg.rect([
        @svg.X["\{x_right - sample_w}"],
        @svg.Y["\{y0}"],
        @svg.Width["\{sample_w - 2}"],
        @svg.Height["\{sample_h}"],
        @svg.Fill[fill],
      ])
    } else {
      @svg.rect([
        @svg.X["\{x_right - sample_w}"],
        @svg.Y["\{y0}"],
        @svg.Width["\{sample_w - 2}"],
        @svg.Height["\{sample_h}"],
        @svg.Fill[fill],
        @svg.Stroke[stroke],
        @svg.StrokeWidth["\{stroke_width}"],
      ])
    }
    let label = @svg.text(
      [
        @svg.X["\{x_right}"],
        @svg.Y["\{y + (font_size / 3)}"],
        @svg.FontSize["\{font_size}"],
        @svg.TextAnchor["end"],
        @svg.Fill["#000"],
      ],
      child=@svg.Element::str(name),
    )
    @svg.g([]) + sample + label
  }
}

///|
/// 生成多条折线图（Float 版）：
/// - y 轴范围取所有 series 的 min/max
/// - x 轴按“最长 series”的长度对齐（索引等距）
pub fn line_chart_series_float(
  series~ : Array[LineSeriesFloat],
  width? : Int = 600,
  height? : Int = 200,
  padding? : Padding = padding(20),
  x_ticks? : Int = 5,
  y_ticks? : Int = 5,
  axis_font_size? : Int = 10,
  show_axes? : Bool = true,
  show_legend? : Bool = true,
) -> @svg.Element {
  line_chart_series_float_with_options(
    series~,
    options=series_chart_options(
      base=chart_options(
        width~,
        height~,
        padding~,
        x_ticks~,
        y_ticks~,
        axis_font_size~,
        show_axes~,
      ),
      show_legend~,
    ),
  )
}

///|
/// 使用统一 options 的多折线（Float 版）入口。
pub fn line_chart_series_float_with_options(
  series~ : Array[LineSeriesFloat],
  options~ : SeriesChartOptions,
) -> @svg.Element {
  let base = options.base
  let max_len = max_len_series_float(series)
  let x_denom = if max_len <= 1 { 1 } else { max_len - 1 }
  let (minv, maxv) = min_max_series_float(series)
  let low = if minv > 0.0 { 0.0 } else { minv }
  let high = if maxv < 0.0 { 0.0 } else { maxv }
  let lay = layout_for_float_axis(base, low, high, max_len)
  let lines = loop (0, @svg.g([])) {
    (i, acc) if i >= series.length() => acc
    (i, acc) => {
      let s = series[i]
      let d = line_path_d_scaled_float(
        s.data,
        low,
        high,
        x_denom,
        lay.plot_left,
        lay.plot_top,
        lay.plot_width,
        lay.plot_height,
      )
      let one = if d == "" {
        @svg.g([])
      } else {
        @svg.path([
          @svg.D[d],
          @svg.Fill["none"],
          @svg.Stroke[s.stroke],
          @svg.StrokeWidth["\{s.stroke_width}"],
        ])
      }
      continue (i + 1, acc + one)
    }
  }
  let axis_color = "#000"
  let axis_layer = axis_layer_float(base, lay, low, high, max_len, axis_color)
  let legend = if options.show_legend {
    legend_layer_float(
      series,
      lay.plot_left,
      lay.plot_top,
      lay.plot_width,
      base.axis_font_size,
    )
  } else {
    @svg.g([])
  }
  svg_doc(axis_layer + legend + lines, lay.w, lay.h)
}

///|
/// 生成折线图（Float 版）：
/// - `data`：数据点（Float），x 轴按索引均匀分布
pub fn line_chart_float(
  data~ : Array[Double],
  width? : Int = 600,
  height? : Int = 200,
  padding? : Padding = padding(20),
  stroke? : String = "#3355cc",
  stroke_width? : Int = 2,
  x_ticks? : Int = 5,
  y_ticks? : Int = 5,
  axis_font_size? : Int = 10,
  show_axes? : Bool = true,
) -> @svg.Element {
  line_chart_float_with_options(
    data~,
    options=chart_options(
      width~,
      height~,
      padding~,
      x_ticks~,
      y_ticks~,
      axis_font_size~,
      show_axes~,
    ),
    stroke~,
    stroke_width~,
  )
}

///|
/// 使用统一 options 的折线图（Float 版）入口。
pub fn line_chart_float_with_options(
  data~ : Array[Double],
  options~ : ChartOptions,
  stroke? : String = "#3355cc",
  stroke_width? : Int = 2,
) -> @svg.Element {
  let n = data.length()
  let x_denom = if n <= 1 { 1 } else { n - 1 }
  let (minv, maxv) = min_max_float(data)
  let low = if minv > 0.0 { 0.0 } else { minv }
  let high = if maxv < 0.0 { 0.0 } else { maxv }
  let lay = layout_for_float_axis(options, low, high, n)
  let d = line_path_d_scaled_float(
    data,
    low,
    high,
    x_denom,
    lay.plot_left,
    lay.plot_top,
    lay.plot_width,
    lay.plot_height,
  )
  let line = if d == "" {
    @svg.g([])
  } else {
    @svg.path([
      @svg.D[d],
      @svg.Fill["none"],
      @svg.Stroke[stroke],
      @svg.StrokeWidth["\{stroke_width}"],
    ])
  }
  let axis_color = "#000"
  let axis_layer = axis_layer_float(options, lay, low, high, n, axis_color)
  svg_doc(axis_layer + line, lay.w, lay.h)
}

///|
/// 生成柱状图（Float 版）：
/// - `data`：每个柱子的高度值（Float）
pub fn bar_chart_float(
  data~ : Array[Double],
  width? : Int = 600,
  height? : Int = 200,
  padding? : Padding = padding(20),
  fill? : String = "#3355cc",
  x_ticks? : Int = 5,
  y_ticks? : Int = 5,
  axis_font_size? : Int = 10,
  show_axes? : Bool = true,
) -> @svg.Element {
  bar_chart_float_with_options(
    data~,
    options=chart_options(
      width~,
      height~,
      padding~,
      x_ticks~,
      y_ticks~,
      axis_font_size~,
      show_axes~,
    ),
    fill~,
  )
}

///|
/// 使用统一 options 的柱状图（Float 版）入口。
pub fn bar_chart_float_with_options(
  data~ : Array[Double],
  options~ : ChartOptions,
  fill? : String = "#3355cc",
  name? : String = "",
  stroke? : String = "",
  stroke_width? : Int = 1,
) -> @svg.Element {
  let n = data.length()
  let (minv, maxv) = min_max_float(data)
  let low = if minv > 0.0 { 0.0 } else { minv }
  let high = if maxv < 0.0 { 0.0 } else { maxv }
  let lay = layout_for_float_axis(options, low, high, n)
  let range = {
    let r = high - low
    if r == 0.0 {
      1.0
    } else {
      r
    }
  }
  let y0 = lay.plot_top.to_double() +
    (high - 0.0) * lay.plot_height.to_double() / range
  let (slot, bar_w, x_pad) = bar_slot_and_width(lay.plot_width, n)
  let bars = loop (0, @svg.g([])) {
    (i, acc) if i >= n => acc
    (i, acc) => {
      let v = data[i]
      let x = lay.plot_left + i * slot + x_pad
      let yv = lay.plot_top.to_double() +
        (high - v) * lay.plot_height.to_double() / range
      let y = if yv < y0 { yv } else { y0 }
      let bar_h = {
        let h = if yv < y0 { y0 - yv } else { yv - y0 }
        if h <= 0.0 {
          0.0
        } else {
          h
        }
      }
      let rect = if stroke == "" {
        @svg.rect([
          @svg.X["\{x}"],
          @svg.Y["\{y}"],
          @svg.Width["\{bar_w}"],
          @svg.Height["\{bar_h}"],
          @svg.Fill[fill],
        ])
      } else {
        @svg.rect([
          @svg.X["\{x}"],
          @svg.Y["\{y}"],
          @svg.Width["\{bar_w}"],
          @svg.Height["\{bar_h}"],
          @svg.Fill[fill],
          @svg.Stroke[stroke],
          @svg.StrokeWidth["\{stroke_width}"],
        ])
      }
      continue (i + 1, acc + rect)
    }
  }
  let axis_color = "#000"
  let axis_layer = axis_layer_float(options, lay, low, high, n, axis_color)
  let legend = bar_legend_layer(
    name,
    fill,
    stroke,
    stroke_width,
    lay.plot_left,
    lay.plot_top,
    lay.plot_width,
    options.axis_font_size,
  )
  svg_doc(axis_layer + legend + bars, lay.w, lay.h)
}

///|
/// 生成多条折线图：
/// - y 轴范围取所有 series 的 min/max
/// - x 轴按“最长 series”的长度对齐（索引等距）
pub fn line_chart_series(
  series~ : Array[LineSeries],
  width? : Int = 600,
  height? : Int = 200,
  padding? : Padding = padding(20),
  x_ticks? : Int = 5,
  y_ticks? : Int = 5,
  axis_font_size? : Int = 10,
  show_axes? : Bool = true,
  show_legend? : Bool = true,
) -> @svg.Element {
  line_chart_series_with_options(
    series~,
    options=series_chart_options(
      base=chart_options(
        width~,
        height~,
        padding~,
        x_ticks~,
        y_ticks~,
        axis_font_size~,
        show_axes~,
      ),
      show_legend~,
    ),
  )
}

///|
/// 使用统一 options 的多折线（Int 版）入口。
pub fn line_chart_series_with_options(
  series~ : Array[LineSeries],
  options~ : SeriesChartOptions,
) -> @svg.Element {
  let base = options.base
  let max_len = max_len_series(series)
  let x_denom = if max_len <= 1 { 1 } else { max_len - 1 }
  let (minv, maxv) = min_max_series(series)
  let low = if minv > 0 { 0 } else { minv }
  let high = if maxv < 0 { 0 } else { maxv }
  let lay = layout_for_int_axis(base, low, high, max_len)
  let lines = loop (0, @svg.g([])) {
    (i, acc) if i >= series.length() => acc
    (i, acc) => {
      let s = series[i]
      let d = line_path_d_scaled(
        s.data,
        low,
        high,
        x_denom,
        lay.plot_left,
        lay.plot_top,
        lay.plot_width,
        lay.plot_height,
      )
      let one = if d == "" {
        @svg.g([])
      } else {
        @svg.path([
          @svg.D[d],
          @svg.Fill["none"],
          @svg.Stroke[s.stroke],
          @svg.StrokeWidth["\{s.stroke_width}"],
        ])
      }
      continue (i + 1, acc + one)
    }
  }
  let axis_color = "#000"
  let axis_layer = axis_layer_int(base, lay, low, high, max_len, axis_color)
  let legend = if options.show_legend {
    legend_layer(
      series,
      lay.plot_left,
      lay.plot_top,
      lay.plot_width,
      base.axis_font_size,
    )
  } else {
    @svg.g([])
  }
  svg_doc(axis_layer + legend + lines, lay.w, lay.h)
}

///|
/// 生成折线图（最小版本）：
/// - `data`：数据点（Int），x 轴按索引均匀分布
/// - 返回值是 `@svg.Element`，可直接 `println` 输出 SVG 字符串
pub fn line_chart(
  data~ : Array[Int],
  width? : Int = 600,
  height? : Int = 200,
  padding? : Padding = padding(20),
  stroke? : String = "#3355cc",
  stroke_width? : Int = 2,
  x_ticks? : Int = 5,
  y_ticks? : Int = 5,
  axis_font_size? : Int = 10,
  show_axes? : Bool = true,
) -> @svg.Element {
  line_chart_with_options(
    data~,
    options=chart_options(
      width~,
      height~,
      padding~,
      x_ticks~,
      y_ticks~,
      axis_font_size~,
      show_axes~,
    ),
    stroke~,
    stroke_width~,
  )
}

///|
/// 使用统一 options 的折线图（Int 版）入口。
pub fn line_chart_with_options(
  data~ : Array[Int],
  options~ : ChartOptions,
  stroke? : String = "#3355cc",
  stroke_width? : Int = 2,
) -> @svg.Element {
  let n = data.length()
  let x_denom = if n <= 1 { 1 } else { n - 1 }
  let (minv, maxv) = min_max_int(data)
  let low = if minv > 0 { 0 } else { minv }
  let high = if maxv < 0 { 0 } else { maxv }
  let lay = layout_for_int_axis(options, low, high, n)
  let d = line_path_d_scaled(
    data,
    low,
    high,
    x_denom,
    lay.plot_left,
    lay.plot_top,
    lay.plot_width,
    lay.plot_height,
  )
  let line = if d == "" {
    @svg.g([])
  } else {
    @svg.path([
      @svg.D[d],
      @svg.Fill["none"],
      @svg.Stroke[stroke],
      @svg.StrokeWidth["\{stroke_width}"],
    ])
  }
  let axis_color = "#000"
  let axis_layer = axis_layer_int(options, lay, low, high, n, axis_color)
  svg_doc(axis_layer + line, lay.w, lay.h)
}

///|
/// 生成柱状图（最小版本）：
/// - `data`：每个柱子的高度值（Int）
pub fn bar_chart(
  data~ : Array[Int],
  width? : Int = 600,
  height? : Int = 200,
  padding? : Padding = padding(20),
  fill? : String = "#3355cc",
  x_ticks? : Int = 5,
  y_ticks? : Int = 5,
  axis_font_size? : Int = 10,
  show_axes? : Bool = true,
) -> @svg.Element {
  bar_chart_with_options(
    data~,
    options=chart_options(
      width~,
      height~,
      padding~,
      x_ticks~,
      y_ticks~,
      axis_font_size~,
      show_axes~,
    ),
    fill~,
  )
}

///|
/// 使用统一 options 的柱状图（Int 版）入口。
pub fn bar_chart_with_options(
  data~ : Array[Int],
  options~ : ChartOptions,
  fill? : String = "#3355cc",
  name? : String = "",
  stroke? : String = "",
  stroke_width? : Int = 1,
) -> @svg.Element {
  let n = data.length()
  let (minv, maxv) = min_max_int(data)
  let low = if minv > 0 { 0 } else { minv }
  let high = if maxv < 0 { 0 } else { maxv }
  let lay = layout_for_int_axis(options, low, high, n)
  let range = {
    let r = high - low
    if r == 0 {
      1
    } else {
      r
    }
  }
  let y0 = lay.plot_top + (high - 0) * lay.plot_height / range
  let (slot, bar_w, x_pad) = bar_slot_and_width(lay.plot_width, n)
  let bars = loop (0, @svg.g([])) {
    (i, acc) if i >= n => acc
    (i, acc) => {
      let v = data[i]
      let x = lay.plot_left + i * slot + x_pad
      let yv = lay.plot_top + (high - v) * lay.plot_height / range
      let y = if yv < y0 { yv } else { y0 }
      let bar_h = {
        let h = if yv < y0 { y0 - yv } else { yv - y0 }
        if h <= 0 {
          0
        } else {
          h
        }
      }
      let rect = if stroke == "" {
        @svg.rect([
          @svg.X["\{x}"],
          @svg.Y["\{y}"],
          @svg.Width["\{bar_w}"],
          @svg.Height["\{bar_h}"],
          @svg.Fill[fill],
        ])
      } else {
        @svg.rect([
          @svg.X["\{x}"],
          @svg.Y["\{y}"],
          @svg.Width["\{bar_w}"],
          @svg.Height["\{bar_h}"],
          @svg.Fill[fill],
          @svg.Stroke[stroke],
          @svg.StrokeWidth["\{stroke_width}"],
        ])
      }
      continue (i + 1, acc + rect)
    }
  }
  let axis_color = "#000"
  let axis_layer = axis_layer_int(options, lay, low, high, n, axis_color)
  let legend = bar_legend_layer(
    name,
    fill,
    stroke,
    stroke_width,
    lay.plot_left,
    lay.plot_top,
    lay.plot_width,
    options.axis_font_size,
  )
  svg_doc(axis_layer + legend + bars, lay.w, lay.h)
}
