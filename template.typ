#let border-stroke-thickness = 0.14em
#let heading-banner-corner-radius = 0.5mm
#let heading-banner-inner-padding = (x: 0.43em, y: 0.31em)
#let page-margin-horizontal = 0.1in
#let page-margin-vertical = 0.3in
#let section-box-corner-radius = 0.35em
#let section-box-inner-padding = 0.57em
#let table-stroke-thickness = 0.06em
#let table-stroke-fallback-color = luma(100)
#let table-inset = (x: 0.55em, y: 0.38em)
#let table-cell-inset = (x: 0.4em, y: 0.45em)
#let text-line-spacing = 0.45em
#let vertical-element-spacing = 0.7em

#let __default-color-palette = (
  rgb(255, 195, 145),
  rgb(172, 134, 212),
  rgb(250, 165, 165),
  rgb(115, 145, 195),
  rgb(232, 180, 72),
  rgb(175, 110, 125),
  rgb(115, 195, 160),
  rgb(198, 160, 130),
  rgb(88, 155, 165),
  rgb(210, 135, 110),
  rgb(155, 182, 112),
  rgb(175, 115, 155),
)

#let __theme-palette-state = state("theme-palette-state", __default-color-palette)

#let __get-theme-color(target-location, heading-depth: 1) = {
  let section-heading-counter = counter(heading).at(target-location).first()
  let zero-based-section-index = section-heading-counter - 1
  let active-color-palette = __theme-palette-state.at(target-location)
  let palette-color-index = calc.rem(zero-based-section-index, active-color-palette.len())
  let base-section-color = active-color-palette.at(palette-color-index)
  let depth-darkening-percentage = 8% * (heading-depth - 1)

  base-section-color.lighten(depth-darkening-percentage)
}

#let __section-divider(divider-title) = context {
  let divider-accent-color = __get-theme-color(here(), heading-depth: 2)
  let horizontal-rule = line(length: 100%, stroke: border-stroke-thickness + divider-accent-color)

  block(
    width: 100%,
    above: vertical-element-spacing,
    below: vertical-element-spacing,
    grid(
      columns: (1fr, auto, 1fr),
      align: horizon + center,
      column-gutter: 0.8em,
      horizontal-rule, text(fill: divider-accent-color, weight: "bold")[#divider-title], horizontal-rule,
    ),
  )
}

#let section-block(
  content-alignment: start,
  block-width: 100%,
  background-color: white,
  section-content,
) = context {
  let section-stroke-color = __get-theme-color(here())
  let section-table-stroke-color = __get-theme-color(here(), heading-depth: -4)

  block(
    stroke: border-stroke-thickness + section-stroke-color,
    radius: section-box-corner-radius,
    inset: section-box-inner-padding,
    width: block-width,
    {
      set table(
        stroke: (x, y) => (
          left: if x > 0 { table-stroke-thickness + section-table-stroke-color } else { none },
          top: if y > 0 { table-stroke-thickness + section-table-stroke-color } else { none },
          right: none,
          bottom: none,
        ),
      )
      align(content-alignment, section-content)
    },
  )
}

#let template(
  title: [],
  authors: (),
  date: datetime.today(),
  font-size: 7pt,
  column-count: 4,
  column-gutter: 0.3em,
  color-palette: __default-color-palette,
  document-body,
) = {
  __theme-palette-state.update(color-palette)

  let formatted-authors-text = if type(authors) == array {
    authors.join(", ")
  } else {
    str(authors)
  }

  let formatted-header-date = if type(date) == datetime {
    date.display("[month repr:long] [day], [year]")
  } else {
    date
  }

  set page(
    paper: "us-letter",
    flipped: true,
    margin: (x: page-margin-horizontal, y: page-margin-vertical),
    header: [
      #grid(
        columns: (1fr, 1fr, 1fr),
        align: (left, center, right),
        text(formatted-header-date, weight: "bold"),
        text(title, weight: "bold"),
        text(formatted-authors-text, weight: "bold"),
      )
      #v(-vertical-element-spacing)
      #line(length: 100%, stroke: border-stroke-thickness + black)
    ],
  )

  set heading(numbering: "1.1")
  set text(size: font-size)
  set par(leading: text-line-spacing)

  set table(
    align: left,
    inset: table-inset,
    stroke: (x, y) => (
      left: if x > 0 { table-stroke-thickness + table-stroke-fallback-color } else { none },
      top: if y > 0 { table-stroke-thickness + table-stroke-fallback-color } else { none },
      right: none,
      bottom: none,
    ),
  )

  set table.cell(inset: table-cell-inset)
  show table.cell.where(y: 0): set text(weight: "bold")

  show heading: heading-element => context {
    set text(size: font-size)

    if heading-element.depth == 2 {
      __section-divider(heading-element.body)
    } else {
      let heading-background-color = __get-theme-color(
        heading-element.location(),
        heading-depth: heading-element.depth,
      )

      set text(white)
      set align(center)
      block(
        fill: heading-background-color,
        radius: heading-banner-corner-radius,
        inset: heading-banner-inner-padding,
        width: 100%,
        above: vertical-element-spacing,
        below: vertical-element-spacing,
        heading-element.body,
      )
    }
  }

  columns(column-count, gutter: column-gutter, document-body)
}
