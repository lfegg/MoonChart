///|
test "line_chart" {
  let svg = line_chart(
    data=[10, 20, 15],
    width=120,
    height=60,
    x_ticks=3,
    y_ticks=3,
    axis_font_size=8,
  )
  // 输出是稳定的 SVG markup；如后续调整渲染细节，可运行 `moon test --update` 更新快照。
  inspect(
    svg,
    content=(
      #|<!DOCTYPE svg><svg height="60" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 60" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="120"><line stroke-width="1" y2="40" y1="40" stroke="#000" x2="100" x1="20"/><line stroke-width="1" y2="40" y1="20" stroke="#000" x2="20" x1="20"/><g/><line stroke-width="1" y2="40" y1="40" stroke="#000" x2="16" x1="20"/><text fill="#000" text-anchor="end" x="14" y="42" font-size="8">0</text><line stroke-width="1" y2="30" y1="30" stroke="#000" x2="16" x1="20"/><text fill="#000" text-anchor="end" x="14" y="32" font-size="8">10</text><line stroke-width="1" y2="20" y1="20" stroke="#000" x2="16" x1="20"/><text fill="#000" text-anchor="end" x="14" y="22" font-size="8">20</text><g/><line stroke-width="1" y2="44" y1="40" stroke="#000" x2="20" x1="20"/><text fill="#000" text-anchor="middle" x="20" y="52" font-size="8">0</text><line stroke-width="1" y2="44" y1="40" stroke="#000" x2="60" x1="60"/><text fill="#000" text-anchor="middle" x="60" y="52" font-size="8">1</text><line stroke-width="1" y2="44" y1="40" stroke="#000" x2="100" x1="100"/><text fill="#000" text-anchor="middle" x="100" y="52" font-size="8">2</text><path fill="none" stroke-width="2" stroke="#3355cc" d="M 20,30 L 60,20 L 100,25 "/></svg>
    ),
  )
}

///|
test "bar_chart" {
  let svg = bar_chart(
    data=[1, 2, 3],
    width=120,
    height=60,
    x_ticks=3,
    y_ticks=3,
    axis_font_size=8,
  )
  inspect(
    svg,
    content=(
      #|<!DOCTYPE svg><svg height="60" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 60" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="120"><line stroke-width="1" y2="40" y1="40" stroke="#000" x2="100" x1="20"/><line stroke-width="1" y2="40" y1="20" stroke="#000" x2="20" x1="20"/><g/><line stroke-width="1" y2="40" y1="40" stroke="#000" x2="16" x1="20"/><text fill="#000" text-anchor="end" x="14" y="42" font-size="8">0</text><line stroke-width="1" y2="33" y1="33" stroke="#000" x2="16" x1="20"/><text fill="#000" text-anchor="end" x="14" y="35" font-size="8">1</text><line stroke-width="1" y2="20" y1="20" stroke="#000" x2="16" x1="20"/><text fill="#000" text-anchor="end" x="14" y="22" font-size="8">3</text><g/><line stroke-width="1" y2="44" y1="40" stroke="#000" x2="20" x1="20"/><text fill="#000" text-anchor="middle" x="20" y="52" font-size="8">0</text><line stroke-width="1" y2="44" y1="40" stroke="#000" x2="60" x1="60"/><text fill="#000" text-anchor="middle" x="60" y="52" font-size="8">1</text><line stroke-width="1" y2="44" y1="40" stroke="#000" x2="100" x1="100"/><text fill="#000" text-anchor="middle" x="100" y="52" font-size="8">2</text><g/><g/><rect fill="#3355cc" height="7" x="23" width="20" y="33"/><rect fill="#3355cc" height="14" x="49" width="20" y="26"/><rect fill="#3355cc" height="20" x="75" width="20" y="20"/></svg>
    ),
  )
}

///|
test "line_chart_series" {
  let svg = line_chart_series(
    series=[
      line_series(data=[10, 20, 15], name="A", stroke="#3355cc", stroke_width=2),
      line_series(data=[12, 18, 14], name="B", stroke="#000", stroke_width=1),
    ],
    width=120,
    height=60,
    x_ticks=3,
    y_ticks=3,
    axis_font_size=8,
  )
  inspect(
    svg,
    content=(
      #|<!DOCTYPE svg><svg height="60" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 60" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="120"><line stroke-width="1" y2="40" y1="40" stroke="#000" x2="100" x1="20"/><line stroke-width="1" y2="40" y1="20" stroke="#000" x2="20" x1="20"/><g/><line stroke-width="1" y2="40" y1="40" stroke="#000" x2="16" x1="20"/><text fill="#000" text-anchor="end" x="14" y="42" font-size="8">0</text><line stroke-width="1" y2="30" y1="30" stroke="#000" x2="16" x1="20"/><text fill="#000" text-anchor="end" x="14" y="32" font-size="8">10</text><line stroke-width="1" y2="20" y1="20" stroke="#000" x2="16" x1="20"/><text fill="#000" text-anchor="end" x="14" y="22" font-size="8">20</text><g/><line stroke-width="1" y2="44" y1="40" stroke="#000" x2="20" x1="20"/><text fill="#000" text-anchor="middle" x="20" y="52" font-size="8">0</text><line stroke-width="1" y2="44" y1="40" stroke="#000" x2="60" x1="60"/><text fill="#000" text-anchor="middle" x="60" y="52" font-size="8">1</text><line stroke-width="1" y2="44" y1="40" stroke="#000" x2="100" x1="100"/><text fill="#000" text-anchor="middle" x="100" y="52" font-size="8">2</text><g/><line stroke-width="2" y2="22" y1="22" stroke="#3355cc" x2="96" x1="84"/><text fill="#000" text-anchor="end" x="98" y="24" font-size="8">A</text><line stroke-width="1" y2="34" y1="34" stroke="#000" x2="96" x1="84"/><text fill="#000" text-anchor="end" x="98" y="36" font-size="8">B</text><g/><path fill="none" stroke-width="2" stroke="#3355cc" d="M 20,30 L 60,20 L 100,25 "/><path fill="none" stroke-width="1" stroke="#000" d="M 20,28 L 60,22 L 100,26 "/></svg>
    ),
  )
}

///|
test "line_chart_float" {
  let svg = line_chart_float(
    data=[0.0, 2.5, 5.0, 7.5, 10.0],
    width=120,
    height=60,
    padding=padding(10),
    x_ticks=3,
    y_ticks=3,
    axis_font_size=8,
  )
  inspect(
    svg,
    content=(
      #|<!DOCTYPE svg><svg height="60" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 60" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="120"><line stroke-width="1" y2="50" y1="50" stroke="#000" x2="110" x1="17"/><line stroke-width="1" y2="50" y1="10" stroke="#000" x2="17" x1="17"/><g/><line stroke-width="1" y2="50" y1="50" stroke="#000" x2="13" x1="17"/><text fill="#000" text-anchor="end" x="11" y="52" font-size="8">0</text><line stroke-width="1" y2="30" y1="30" stroke="#000" x2="13" x1="17"/><text fill="#000" text-anchor="end" x="11" y="32" font-size="8">5</text><line stroke-width="1" y2="10" y1="10" stroke="#000" x2="13" x1="17"/><text fill="#000" text-anchor="end" x="11" y="12" font-size="8">10</text><g/><line stroke-width="1" y2="54" y1="50" stroke="#000" x2="17" x1="17"/><text fill="#000" text-anchor="middle" x="17" y="62" font-size="8">0</text><line stroke-width="1" y2="54" y1="50" stroke="#000" x2="63" x1="63"/><text fill="#000" text-anchor="middle" x="63" y="62" font-size="8">2</text><line stroke-width="1" y2="54" y1="50" stroke="#000" x2="110" x1="110"/><text fill="#000" text-anchor="middle" x="110" y="62" font-size="8">4</text><path fill="none" stroke-width="2" stroke="#3355cc" d="M 17,50 L 40,40 L 63,30 L 86,20 L 110,10 "/></svg>
    ),
  )
}

///|
test "bar_chart_float" {
  let svg = bar_chart_float(
    data=[0.0, 2.5, 5.0],
    width=120,
    height=60,
    padding=padding(10),
    x_ticks=3,
    y_ticks=3,
    axis_font_size=8,
  )
  inspect(
    svg,
    content=(
      #|<!DOCTYPE svg><svg height="60" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 60" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="120"><line stroke-width="1" y2="50" y1="50" stroke="#000" x2="110" x1="22"/><line stroke-width="1" y2="50" y1="10" stroke="#000" x2="22" x1="22"/><g/><line stroke-width="1" y2="50" y1="50" stroke="#000" x2="18" x1="22"/><text fill="#000" text-anchor="end" x="16" y="52" font-size="8">0</text><line stroke-width="1" y2="30" y1="30" stroke="#000" x2="18" x1="22"/><text fill="#000" text-anchor="end" x="16" y="32" font-size="8">2.5</text><line stroke-width="1" y2="10" y1="10" stroke="#000" x2="18" x1="22"/><text fill="#000" text-anchor="end" x="16" y="12" font-size="8">5</text><g/><line stroke-width="1" y2="54" y1="50" stroke="#000" x2="22" x1="22"/><text fill="#000" text-anchor="middle" x="22" y="62" font-size="8">0</text><line stroke-width="1" y2="54" y1="50" stroke="#000" x2="66" x1="66"/><text fill="#000" text-anchor="middle" x="66" y="62" font-size="8">1</text><line stroke-width="1" y2="54" y1="50" stroke="#000" x2="110" x1="110"/><text fill="#000" text-anchor="middle" x="110" y="62" font-size="8">2</text><g/><g/><rect fill="#3355cc" height="0" x="25" width="23" y="50"/><rect fill="#3355cc" height="20" x="54" width="23" y="30"/><rect fill="#3355cc" height="40" x="83" width="23" y="10"/></svg>
    ),
  )
}

///|
test "line_chart_series_float" {
  let svg = line_chart_series_float(
    series=[
      line_series_float(
        data=[0.0, 2.5, 5.0],
        name="A",
        stroke="#3355cc",
        stroke_width=2,
      ),
      line_series_float(
        data=[5.0, 2.5, 0.0],
        name="B",
        stroke="#000",
        stroke_width=1,
      ),
    ],
    width=120,
    height=60,
    padding=padding(10),
    x_ticks=3,
    y_ticks=3,
    axis_font_size=8,
  )
  inspect(
    svg,
    content=(
      #|<!DOCTYPE svg><svg height="60" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 60" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="120"><line stroke-width="1" y2="50" y1="50" stroke="#000" x2="110" x1="22"/><line stroke-width="1" y2="50" y1="10" stroke="#000" x2="22" x1="22"/><g/><line stroke-width="1" y2="50" y1="50" stroke="#000" x2="18" x1="22"/><text fill="#000" text-anchor="end" x="16" y="52" font-size="8">0</text><line stroke-width="1" y2="30" y1="30" stroke="#000" x2="18" x1="22"/><text fill="#000" text-anchor="end" x="16" y="32" font-size="8">2.5</text><line stroke-width="1" y2="10" y1="10" stroke="#000" x2="18" x1="22"/><text fill="#000" text-anchor="end" x="16" y="12" font-size="8">5</text><g/><line stroke-width="1" y2="54" y1="50" stroke="#000" x2="22" x1="22"/><text fill="#000" text-anchor="middle" x="22" y="62" font-size="8">0</text><line stroke-width="1" y2="54" y1="50" stroke="#000" x2="66" x1="66"/><text fill="#000" text-anchor="middle" x="66" y="62" font-size="8">1</text><line stroke-width="1" y2="54" y1="50" stroke="#000" x2="110" x1="110"/><text fill="#000" text-anchor="middle" x="110" y="62" font-size="8">2</text><g/><line stroke-width="2" y2="12" y1="12" stroke="#3355cc" x2="106" x1="94"/><text fill="#000" text-anchor="end" x="108" y="14" font-size="8">A</text><line stroke-width="1" y2="24" y1="24" stroke="#000" x2="106" x1="94"/><text fill="#000" text-anchor="end" x="108" y="26" font-size="8">B</text><g/><path fill="none" stroke-width="2" stroke="#3355cc" d="M 22,50 L 66,30 L 110,10 "/><path fill="none" stroke-width="1" stroke="#000" d="M 22,10 L 66,30 L 110,50 "/></svg>
    ),
  )
}

///|
test "line_chart_float_precision" {
  let options = chart_options(float_label_precision=2)
  let svg = line_chart_float_with_options(
    data=[0.0, 1.0, 2.0, 3.0, 4.0],
    options~,
  )
  inspect(
    svg,
    content=(
      #|<!DOCTYPE svg><svg height="200" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 200" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="600"><line stroke-width="1" y2="180" y1="180" stroke="#000" x2="580" x1="32"/><line stroke-width="1" y2="180" y1="20" stroke="#000" x2="32" x1="32"/><g/><line stroke-width="1" y2="180" y1="180" stroke="#000" x2="28" x1="32"/><text fill="#000" text-anchor="end" x="26" y="183" font-size="10">0.00</text><line stroke-width="1" y2="140" y1="140" stroke="#000" x2="28" x1="32"/><text fill="#000" text-anchor="end" x="26" y="143" font-size="10">1.00</text><line stroke-width="1" y2="100" y1="100" stroke="#000" x2="28" x1="32"/><text fill="#000" text-anchor="end" x="26" y="103" font-size="10">2.00</text><line stroke-width="1" y2="60" y1="60" stroke="#000" x2="28" x1="32"/><text fill="#000" text-anchor="end" x="26" y="63" font-size="10">3.00</text><line stroke-width="1" y2="20" y1="20" stroke="#000" x2="28" x1="32"/><text fill="#000" text-anchor="end" x="26" y="23" font-size="10">4.00</text><g/><line stroke-width="1" y2="184" y1="180" stroke="#000" x2="32" x1="32"/><text fill="#000" text-anchor="middle" x="32" y="194" font-size="10">0</text><line stroke-width="1" y2="184" y1="180" stroke="#000" x2="169" x1="169"/><text fill="#000" text-anchor="middle" x="169" y="194" font-size="10">1</text><line stroke-width="1" y2="184" y1="180" stroke="#000" x2="306" x1="306"/><text fill="#000" text-anchor="middle" x="306" y="194" font-size="10">2</text><line stroke-width="1" y2="184" y1="180" stroke="#000" x2="443" x1="443"/><text fill="#000" text-anchor="middle" x="443" y="194" font-size="10">3</text><line stroke-width="1" y2="184" y1="180" stroke="#000" x2="580" x1="580"/><text fill="#000" text-anchor="middle" x="580" y="194" font-size="10">4</text><path fill="none" stroke-width="2" stroke="#3355cc" d="M 32,180 L 169,140 L 306,100 L 443,60 L 580,20 "/></svg>
    ),
  )
}

///|
test "bar_chart_float_named_and_stroked" {
  let options = chart_options(float_label_precision=2)
  let svg = bar_chart_float_with_options(
    data=[10.0, 12.5, 15.0],
    options~,
    fill="#33aa55",
    name="Sales",
    stroke="#114422",
    stroke_width=1,
  )
  inspect(
    svg,
    content=(
      #|<!DOCTYPE svg><svg height="200" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 200" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="600"><line stroke-width="1" y2="180" y1="180" stroke="#000" x2="580" x1="38"/><line stroke-width="1" y2="180" y1="20" stroke="#000" x2="38" x1="38"/><g/><line stroke-width="1" y2="180" y1="180" stroke="#000" x2="34" x1="38"/><text fill="#000" text-anchor="end" x="32" y="183" font-size="10">0.00</text><line stroke-width="1" y2="140" y1="140" stroke="#000" x2="34" x1="38"/><text fill="#000" text-anchor="end" x="32" y="143" font-size="10">3.75</text><line stroke-width="1" y2="100" y1="100" stroke="#000" x2="34" x1="38"/><text fill="#000" text-anchor="end" x="32" y="103" font-size="10">7.50</text><line stroke-width="1" y2="60" y1="60" stroke="#000" x2="34" x1="38"/><text fill="#000" text-anchor="end" x="32" y="63" font-size="10">11.25</text><line stroke-width="1" y2="20" y1="20" stroke="#000" x2="34" x1="38"/><text fill="#000" text-anchor="end" x="32" y="23" font-size="10">15.00</text><g/><line stroke-width="1" y2="184" y1="180" stroke="#000" x2="38" x1="38"/><text fill="#000" text-anchor="middle" x="38" y="194" font-size="10">0</text><line stroke-width="1" y2="184" y1="180" stroke="#000" x2="309" x1="309"/><text fill="#000" text-anchor="middle" x="309" y="194" font-size="10">1</text><line stroke-width="1" y2="184" y1="180" stroke="#000" x2="580" x1="580"/><text fill="#000" text-anchor="middle" x="580" y="194" font-size="10">2</text><g/><rect fill="#33aa55" height="6" stroke-width="1" x="564" stroke="#114422" width="12" y="19"/><text fill="#000" text-anchor="end" x="578" y="25" font-size="10">Sales</text><g/><rect fill="#33aa55" height="106.66666666666666" stroke-width="1" x="56" stroke="#114422" width="144" y="73.33333333333334"/><rect fill="#33aa55" height="133.33333333333331" stroke-width="1" x="236" stroke="#114422" width="144" y="46.66666666666667"/><rect fill="#33aa55" height="160" stroke-width="1" x="416" stroke="#114422" width="144" y="20"/></svg>
    ),
  )
}

///|
test "line_chart_custom_x_labels" {
  let options = chart_options(
    x_ticks=3,
    axis_font_size=8,
    x_labels=Some(["Jan", "Feb", "Mar", "Apr", "May"]),
  )
  let svg = line_chart_with_options(data=[10, 20, 15, 30, 25], options~)
  inspect(svg, content=(
    #|<!DOCTYPE svg><svg height="200" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 200" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="600"><line stroke-width="1" y2="180" y1="180" stroke="#000" x2="580" x1="20"/><line stroke-width="1" y2="180" y1="20" stroke="#000" x2="20" x1="20"/><g/><line stroke-width="1" y2="180" y1="180" stroke="#000" x2="16" x1="20"/><text fill="#000" text-anchor="end" x="14" y="182" font-size="8">0</text><line stroke-width="1" y2="142" y1="142" stroke="#000" x2="16" x1="20"/><text fill="#000" text-anchor="end" x="14" y="144" font-size="8">7</text><line stroke-width="1" y2="100" y1="100" stroke="#000" x2="16" x1="20"/><text fill="#000" text-anchor="end" x="14" y="102" font-size="8">15</text><line stroke-width="1" y2="62" y1="62" stroke="#000" x2="16" x1="20"/><text fill="#000" text-anchor="end" x="14" y="64" font-size="8">22</text><line stroke-width="1" y2="20" y1="20" stroke="#000" x2="16" x1="20"/><text fill="#000" text-anchor="end" x="14" y="22" font-size="8">30</text><g/><line stroke-width="1" y2="184" y1="180" stroke="#000" x2="20" x1="20"/><text fill="#000" text-anchor="middle" x="20" y="192" font-size="8">Jan</text><line stroke-width="1" y2="184" y1="180" stroke="#000" x2="300" x1="300"/><text fill="#000" text-anchor="middle" x="300" y="192" font-size="8">Mar</text><line stroke-width="1" y2="184" y1="180" stroke="#000" x2="580" x1="580"/><text fill="#000" text-anchor="middle" x="580" y="192" font-size="8">May</text><path fill="none" stroke-width="2" stroke="#3355cc" d="M 20,126 L 160,73 L 300,100 L 440,20 L 580,46 "/></svg>
  ))
}
