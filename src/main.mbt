///|
fn main {
  let base = @lib.chart_options(
    width=800,
    height=400,
    x_ticks=5,
    y_ticks=5,
    axis_font_size=12,
    show_points=true,
    point_radius=3,
    // -1 表示默认字符串化；>=0 表示固定小数位
    float_label_precision=2,
  )
  let opt = @lib.series_chart_options(base~, show_legend=true)
  let line_svg : @svg.Element = @lib.line_chart_series_float_with_options(
    series=[
      @lib.line_series_float(
        data=[10.0, 20.0, 15.0],
        name="A",
        stroke="#3355cc",
        stroke_width=2,
      ),
      @lib.line_series_float(
        data=[12.0, 18.0, 14.0],
        name="B",
        stroke="#000",
        stroke_width=1,
      ),
    ],
    options=opt,
  )
  let bar_svg : @svg.Element = @lib.bar_chart_float_with_options(
    data=[10.0, 12.5, 15.0, 17.5, 20.0],
    options=base,
    fill="#33aa55",
    stroke="#114422",
    stroke_width=1,
  )
  println(line_svg)
  println("\n\n---\n\n")
  println(bar_svg)
}
