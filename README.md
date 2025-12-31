# MoonChart

基于 [CAIMEOX/svg](https://mooncakes.io/docs/CAIMEOX/svg) 的 MoonBit SVG 图表库（WIP）。


- 直接生成 `@svg.Element`（可 `println` 输出 SVG 文本）
- 支持折线图/多折线（series）/柱状图
- 同时提供 Int/Float 两套入口
- 坐标轴默认开启，并带“自动留白”避免浏览器裁剪文字
- y 轴范围默认包含 0（避免坐标轴从数据最小值开始产生误导）


## 快速开始

### 折线图（Int）

```moonbit
let svg = @MoonChart.line_chart(
	data=[10, 20, 15, 30, 25],
	width=600,
	height=240,
)
println(svg)
```

### 柱状图（Int）

```moonbit
let svg = @MoonChart.bar_chart(
	data=[5, 12, 9],
	width=600,
	height=240,
)
println(svg)
```

## 核心概念

### 统一 Options（推荐）

为了减少重复参数，建议用 `chart_options(...)` / `series_chart_options(...)` 组合，再调用 `*_with_options` 版本。

另外，坐标轴颜色、文字颜色、默认折线颜色、默认柱子填充色、字体大小等，都可以通过 `ChartStyle`（`chart_style(...)`）统一配置。

折线图如果需要更方便读数，可以开启 `show_points=true` 在折线上绘制点（配合 `point_radius` 调整半径，默认关闭）。

折线图（Int）：

```moonbit
let style = @MoonChart.chart_style(
	axis_color="#000",
	text_color="#000",
	default_line_stroke="#3355cc",
	axis_font_size=12,
)

let opt = @MoonChart.chart_options(
	width=600,
	height=240,
	padding=@MoonChart.padding(20),
	style=style,
	x_ticks=5,
	y_ticks=5,
	show_axes=true,
)

let svg = @MoonChart.line_chart_with_options(
	data=[10, 20, 15, 30, 25],
	options=opt,
	// stroke 为空时会使用 style.default_line_stroke（默认仍为 "#3355cc"）
	stroke="",
	stroke_width=2,
)
println(svg)
```

多折线（Int，带 legend）：

```moonbit
let base = @MoonChart.chart_options(width=600, height=240, axis_font_size=12)
let opt = @MoonChart.series_chart_options(base=base, show_legend=true)

let svg = @MoonChart.line_chart_series_with_options(
	series=[
		@MoonChart.line_series(data=[10, 20, 15], name="A", stroke="#3355cc"),
		@MoonChart.line_series(data=[12, 18, 14], name="B", stroke="#000", stroke_width=1),
	],
	options=opt,
)
println(svg)
```

### Series（多折线）与 legend

- 使用 `line_series(...)` / `line_series_float(...)` 创建每条线
- `name != ""` 时会在右上角显示 legend
- 线条样式由 `stroke`/`stroke_width` 控制

### 自定义 x 轴刻度标签（x_labels）

默认情况下，x 轴标签是索引（`0..n-1`）。如果你需要时间轴/分类名，可以在 `ChartOptions` 里提供 `x_labels`：

```moonbit
let opt = @MoonChart.chart_options(
	width=600,
	height=240,
	x_ticks=3,
	axis_font_size=10,
	x_labels=Some(["Jan", "Feb", "Mar", "Apr", "May"]),
)

let svg = @MoonChart.line_chart_with_options(
	data=[10, 20, 15, 30, 25],
	options=opt,
)
println(svg)
```

说明：

- tick 位置仍按索引均匀分布；`x_ticks` 控制显示多少个标签（会稀疏显示）
- 若 `labels` 长度不足，越界的 idx 会回退显示 idx 字符串

### 折线图点标记（show_points / point_radius）

```moonbit
let opt = @MoonChart.chart_options(
	width=600,
	height=240,
	show_points=true,
	point_radius=2,
)

let svg = @MoonChart.line_chart_with_options(
	data=[10, 20, 15, 30, 25],
	options=opt,
)
println(svg)
```

## Float 数据

当数据包含小数时，使用 `*_float` 版本：

```moonbit
let svg = @MoonChart.line_chart_float(
	data=[0.0, 2.5, 5.0, 7.5, 10.0],
	width=600,
	height=240,
	x_ticks=5,
	y_ticks=5,
	axis_font_size=12,
)
println(svg)
```

### Float 轴标签精度（precision）

默认 Float 轴标签沿用 Double 的字符串化（保持旧行为）。如果想把 y 轴标签固定到指定小数位，可在 `ChartOptions` 中设置 `float_label_precision`：

```moonbit
let opt = @MoonChart.chart_options(
	width=600,
	height=240,
	y_ticks=5,
	axis_font_size=12,
	// -1 表示默认；>=0 表示固定小数位
	float_label_precision=2,
)

let svg = @MoonChart.line_chart_float_with_options(
	data=[0.0, 2.5, 5.0, 7.5, 10.0],
	options=opt,
)
println(svg)
```

## 柱状图增强（legend / stroke）

`bar_chart_with_options` / `bar_chart_float_with_options` 额外支持：

- `name`：右上角柱状图 legend 文本（空字符串表示不显示）
- `stroke` / `stroke_width`：给柱子加边框（`stroke==""` 表示不画边框）

示例（Float）：

```moonbit
let opt = @MoonChart.chart_options(width=600, height=240, float_label_precision=2)
let svg = @MoonChart.bar_chart_float_with_options(
	data=[10.0, 12.5, 15.0],
	options=opt,
	fill="#33aa55",
	name="Sales",
	stroke="#114422",
	stroke_width=1,
)
println(svg)
```

## API 一览

主要入口：

- `line_chart` / `line_chart_with_options`
- `line_chart_series` / `line_chart_series_with_options`
- `bar_chart` / `bar_chart_with_options`
- `line_chart_float` / `line_chart_float_with_options`
- `line_chart_series_float` / `line_chart_series_float_with_options`
- `bar_chart_float` / `bar_chart_float_with_options`

构造与类型：

- `padding(all : Int) -> Padding`
- `chart_options(...) -> ChartOptions`
- `series_chart_options(...) -> SeriesChartOptions`
- `line_series(...) -> LineSeries`
- `line_series_float(...) -> LineSeriesFloat`

