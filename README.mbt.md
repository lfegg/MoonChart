# lfegg/MoonChart

基于 [CAIMEOX/svg](https://mooncakes.io/docs/CAIMEOX/svg) 的 MoonBit SVG 图表库（WIP）。


## 最小示例

折线图（Int）：

```moonbit
let svg = @MoonChart.line_chart(data=[10, 20, 15, 30, 25], width=600, height=240)
println(svg)
```

多折线（Int + legend）：

```moonbit
let opt = @MoonChart.series_chart_options(
	base=@MoonChart.chart_options(width=600, height=240),
	show_legend=true,
)

let svg = @MoonChart.line_chart_series_with_options(
	series=[
		@MoonChart.line_series(data=[10, 20, 15], name="A", stroke="#3355cc"),
		@MoonChart.line_series(data=[12, 18, 14], name="B", stroke="#000", stroke_width=1),
	],
	options=opt,
)
println(svg)
```

柱状图（Float + stroke + legend）：

```moonbit
let base = @MoonChart.chart_options(width=600, height=240, float_label_precision=2)
let svg = @MoonChart.bar_chart_float_with_options(
	data=[10.0, 12.5, 15.0],
	options=base,
	fill="#33aa55",
	name="Sales",
	stroke="#114422",
	stroke_width=1,
)
println(svg)
```

## Options（推荐用法）

- `chart_options(...) -> ChartOptions`：宽高、padding、刻度数、字体、是否显示坐标轴、Float 标签精度、x 轴自定义标签（`x_labels`）
- `series_chart_options(...) -> SeriesChartOptions`：在 `ChartOptions` 上增加 `show_legend`

对应入口：

- `line_chart_with_options` / `line_chart_float_with_options`
- `line_chart_series_with_options` / `line_chart_series_float_with_options`
- `bar_chart_with_options` / `bar_chart_float_with_options`

## 行为说明（简要）

- y 轴范围默认包含 0（避免从最小值起导致视觉误导）
- `show_axes=true` 时启用“自动留白”，减少 y 轴标签/legend 被浏览器裁剪
- `float_label_precision`：`-1` 表示沿用默认字符串化；`>=0` 固定小数位
- `x_labels`：提供 `Some(labels)` 时，x 轴在 tick 位置显示对应标签（越界回退 idx 字符串）

## 开发

仓库内可运行 demo：`moon run src`；测试：`moon test`。
