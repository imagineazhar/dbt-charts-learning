# Module 3: Encodings and axes

dct version: 0.8.0
Date started: 2026-10-06
Board: `boards/m03_encodings.yml`

## Goal

Learn how a chart's colours, time axis and number labels are controlled, and
what a log scale does to skewed data like customer lifetime value.

## Docs read

Offline only: `dct docs color` and `dct docs charts`. Everything below comes
from those pages. Anything I have not run myself is marked **not tried yet**.

## Colour

To split a line into one line per group, point `color:` at a text column, for
example `color: status`. dct draws one series for each value in that column.

The colour itself is not a hex code. It is a **palette token**, a name like
`category[1]` or `positive.solid`. The theme looks the name up and picks the
real colour. Switch theme and the whole board changes with it, which is the
point. A hex code painted on a mark can't follow the theme.

Four kinds of token:

- **Series colours:** `category[1]`, `category[2]`. Numbering starts at 1.
- **Good, bad, warning:** `positive.solid`, `negative.solid`, `warning.solid`.
- **Text, grid and borders:** `dbt-grays.ink`, `dbt-grays.border`.
- **Gradients:** `dbt-seq-blue` for low-to-high, `dbt-div-blue-red` for
  below-and-above a midpoint.

Hex codes still work in most places. The docs say to use one only for a brand
colour that must never change. Two places differ: `palette:` never takes a
single hex, and `conditional_formatting` takes `negative.bg` style tokens but
not `category[1]` style ones.

If a colour is set in two places, the data-driven one (`color: status`) wins
over the fixed one under `style`. A fixed colour goes in `style.color.static`.

I tried a hex code in two places on the lifetime-value chart, which has no
`color:` encoding: `style.color.static: "#336699"` and `style.palette:
"#336699"`. `dct validate` and `dct render` both ran clean. Neither colour
appears in the SVG (no `#336699`, no `rgb(51,102,153)`). So both were accepted
without a message and had no visible effect. **Not tested:** whether I put them
in the wrong place, or whether dct ignores them. Kept out of the draft.

## Time axis

dct looks at the values in the x column and works out the time grain for
itself: day, week, month. If it guesses wrong, set it by hand with
`style.axis_x.time_unit`. The same setting can switch the grouping off.

The valid values, from `dct docs reference`: `auto`, `year`, `yearquarter`,
`yearmonth`, `yearweek`, `yearmonthdate`, `monthofyear`, `dayofweek`,
`dayofmonth`, `dayofyear`, `hourofday`, `none`. The same list is accepted
under `axis_x.ticks.time_unit` and `axis_x.labels.time_unit`, which set how
often ticks and labels appear.

**I tried `yearmonth` on a weekly query and it failed.** `dct validate` passed.
`dct render` stopped with:

```text
ERR-GAP-FILL-BUCKET-COLLISION  Rows with 'week' values datetime.datetime(2018, 
1, 1, 0, 0) and datetime.datetime(2018, 1, 8, 0, 0) both collapse to the 
'yearmonth' bucket '2018-01-01' (status='completed'). Aggregate to yearmonth 
grain in the query before rendering.
At: charts/scratch_t1.yml:25
Docs: dct docs charts
```

The docs explain it: "A
coarser grain places rows in buckets; it does not combine them, and a
last-wins merge would silently discard all but one." Several weekly rows fell
into one month, and dct would not pick one and hide the rest. The fix is in
the query: group by month first. That is the module 1 rule again, enforced
by the tool. The chart never aggregates.

`yearweek` works on the weekly query. The board now uses it.

**Not tested:** `axis_x.fill`, the setting for missing buckets. It may
explain the gaps in the first render.

## Axis labels

Two facts make this easier to remember:

- `axis_y` is always the measure, the number being counted. That stays true
  on a horizontal bar, where the number runs along the bottom.
- The format depends on what the axis holds:

| The axis holds | Where the format goes |
| --- | --- |
| A number (the measure) | `style.number_format` or `style.axis_y.labels.format` |
| Dates | `style.time_format`, for example `"%b %Y"` |
| Text categories | Nothing. No format applies. |

Put a number format on an axis that can't take one and dct stops with
`ERR-LABEL-FORMAT-AXIS-MISMATCH`, at render time.

Axis titles are separate from tick labels. `x_label` and `y_label` sit at the
chart root, level with `type:` and `x:`, not under `style:`. I set
`x_label: "Week"` and the render shows "Week" under the axis.

I set `style.axis_x.labels.format: "%b %d"` on the weekly chart. The ticks now
read `Jan 01`, `Feb 05`, `Mar 05`. They are about five weeks apart, so there
are fewer labels than points.

I triggered it with `style.axis_x.labels.format: "$,.0f"` on the weekly
chart. `dct validate` passed. `dct render` stopped with:

```text
ERR-LABEL-FORMAT-AXIS-MISMATCH  style.axis_x.labels.format ('$,.0f') cannot be 
read on this axis: 'week' holds non-numeric tick labels. This axis is temporal 
— d3's number grammar doesn't read over dates. Author a time spec here (e.g. 
"%b %Y"), or set style.time_format instead.
At: charts/scratch_t2.yml:25
Docs: dct docs charts
```

A different message turned up by itself on the log chart. dct guessed from the
field name that `customer_lifetime_value` is money:

```text
WARN-LIKELY-CURRENCY-OR-PERCENT-MISSING-FORMATTER  cltv_log: Chart 'cltv_log':
field 'customer_lifetime_value' looks like currency but the y-axis format is
'.3~s'.
Fix: Set `style.axis_y.labels.format` to a currency format (e.g. `$,.2f`) or a
percent format (e.g. `.1%`) to match the field's meaning.
```

This is a check on the encoding, not on the data. The default axis format
compacts numbers (`.3~s`), and dct notices that is wrong for a field that looks
like currency. Setting `style.axis_y.labels.format: "$,.0f"` cleared it. The
current board validates with only the two `WARN-DBT-MODEL-COLUMNS-UNRESOLVED`
warnings.

## Log scale

A log scale spaces values by multiples (1, 10, 100) instead of equal steps. It
helps when a few values are huge and the rest are small. Switch it on with
`style.axis_y.scale.continuous.type: log` on a line or area chart.

It can't show zero or negative numbers. The docs say dct refuses a log scale
if any value is 0 or below, and that `type: symlog` is the workaround: it
behaves like log for big values but copes with zero. The docs give the error
code as `ERR-LOG-SCALE-POSITIVE-DATA`. That is not what dct prints (below).

I ran `type: log` on customer lifetime value, ranked from highest to lowest.
There are 62 customers, not 100, and the values run from about 1 to 100. None
is zero, so this data cannot raise the error. The axis is
labelled 1, 2, 3, 5, 10, 20, 30, 50, 100, with uneven grid lines, and its
labels sit on the right of the chart.

To trigger the error I added `UNION ALL SELECT 0` to the query on a throwaway
board. `dct validate` was not run on it. `dct render` stopped with:

```text
ERR-LOG-SCALE-REQUIRES-POSITIVE-DATA  Chart 'cltv_log': column 
'customer_lifetime_value' has a value <= 0, but axis_y.scale.type: log requires
strictly positive data; a log domain is undefined at and below zero. Filter out
the non-positive rows, or drop the log scale.
At: charts/scratch_t3.yml:37
Docs: dct docs charts
```

The real code is `ERR-LOG-SCALE-REQUIRES-POSITIVE-DATA`, not the one in the
docs. The message offers two fixes, filter the rows or drop the log scale, and
does not mention `symlog`.

The board keeps `type: log`. **Not tested here:** `symlog` and the linear axis
are not recorded in this note, so whether a log scale helps with 62 customers
is unanswered. The curriculum says 100 customers; the data has 62.

## What I built

`boards/m03_encodings.yml`: two queries, two line charts, stacked in `rows`.

- **Weekly orders by status.** The query counts orders per week and status. The
  chart puts `week` on x, `orders` on y and `color: status`.
- **Customer lifetime value, ranked.** The query ranks customers by lifetime
  value, one row per customer. The chart puts the rank on x and the value on
  y, with a log scale. My first version selected `order_date` from the
  `customers` model, which has no such column. That model has `first_order`,
  `most_recent_order`, `number_of_orders` and `customer_lifetime_value`. A
  lifetime value is not a weekly number anyway, so I changed the question as
  well as the column.

The query leaves out the final, partial week in SQL, not in the chart. A
reviewer can see and argue with that choice in the diff, which is where the
fix belongs.

The first validate passed with two warnings about titles. I removed the chart
`title:` and they cleared. The current board has a title on both charts and
validate shows no title warnings, so a chart title alone was not the cause. I
do not know what was. Exact warning text: not saved, so it is lost.

The current validate shows only `WARN-DBT-MODEL-COLUMNS-UNRESOLVED`, once for
`orders` and once for `customers`. It is the module 1 warning: both models end
in `select *`, so dct cannot check my column names.

## What the first render showed

Rendered to `assets/renders/m03/m03_encodings.png`.

- **Five lines**, one per status: `completed`, `placed`, `shipped`,
  `returned`, `return_pending`.
- **Only `completed` is a full line.** The other four are short runs. Where a
  status has no orders in a week, dct leaves a gap. It does not draw a zero.
- **The status labels sit at the right end of the lines**, in the line
  colours, in place of a separate legend box. The three lowest ones are
  stacked tightly.
- **The x axis is labelled in months** (Jan, Feb, Mar), although the points
  are weekly. dct picked the grain from the dates. After `time_unit:
  yearweek` the ticks became `Jan 01`, `Feb 05`, `Mar 05` (see Axis labels),
  and `return_pending` shows as two separate dots instead of a short line.
- **The colours are easy to tell apart**, but `placed` and `completed` are
  both blue, one light and one dark. **Not tested** at post size.

What the chart taught me: status is where an order is now, not a type of
order. Old orders are `completed`, March orders are `shipped`, the newest are
`placed`. Splitting a time line by status mixes when an order was placed with
how far it has got. The chart is accurate and misleading, the same lesson as
module 1.

The `completed` line still falls from 3 to 1 at the end, even though the
partial week is gone. My guess is that the newest orders have not finished
yet, so they are still counted under `placed` or `shipped`. **Not tested.**
A query that counts by order date alone would test it.

The subtitle under "M03: Encodings" was the chart `title:`, which I had put
back. The theme also restyles titles: I wrote "Weekly orders by status" and
the render shows "Weekly Orders by Status". Title case is not something the
board controls.

## What the second render showed

The ranked lifetime-value chart falls in steps from about 100 to 1, and on the
log axis the bottom ranks stay readable. Whether a linear axis would hide
them is not tested.

## Validate versus render

All three errors above passed `dct validate` and failed at `dct render`. Each
depends on the rows or on the axis's data type, and validate reads neither.
Validate checks the YAML and the names; render checks the YAML against the
data.

## Post material

`dct docs color` opens with a sentence that is the whole Tableau comparison:
"Colors are palette tokens, not hex — the theme resolves a token, so a board
restyles itself on a theme switch."
