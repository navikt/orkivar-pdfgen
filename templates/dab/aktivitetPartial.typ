#import "/templates/dab/forhaandsorienteringPartial.typ": render-forhaandsorientering
#import "/templates/dab/historikkPartial.typ": render-historikk
#import "/templates/dab/meldingerPartial.typ": render-meldinger

// Converts newlines to Typst linebreaks; handles none/"null" gracefully.
#let breaklines(t) = {
  if t == none or str(t) == "null" { return [] }
  let parts = str(t).split("\n")
  for (i, p) in parts.enumerate() {
    p
    if i < parts.len() - 1 { linebreak() }
  }
}

// Renders a single color-coded label (etikett).
#let render-etikett(e) = {
  let stil = e.at("stil", default: "NEUTRAL")
  let tekst = e.at("tekst", default: "")

  // Color mapping from the CSS classes
  let cfg = if stil == "AVTALT" {
    (fill: rgb("005b82"), stroke: rgb("005b82"), fg: white)
  } else if stil == "POSITIVE" {
    (fill: rgb("ccf1d6"), stroke: rgb("06893a"), fg: rgb("262626"))
  } else if stil == "NEUTRAL" {
    (fill: rgb("d8f9ff"), stroke: rgb("368da8"), fg: rgb("262626"))
  } else {
    // NEGATIVE and fallback
    (fill: rgb("cecece"), stroke: rgb("949292"), fg: rgb("262626"))
  }

  // .etikett { padding: 1px 6px 3px 6px; font-size: 14px = 10.5pt; white-space: nowrap }
  box(
    fill: cfg.fill,
    stroke: 1pt + cfg.stroke,
    inset: (left: 6pt, right: 6pt, top: 3pt, bottom: 5pt),
  )[
    #text(size: 10.5pt, fill: cfg.fg, weight: "regular")[#tekst]
  ]
}

// Renders a single detail field (detalj).
#let render-detalj(d) = {
  let tittel = d.at("tittel", default: "")
  let tekst = d.at("tekst", default: none)
  let stil = d.at("stil", default: "HEL_LINJE")
  let tekst-str = if tekst == none or str(tekst) == "null" { "" } else { str(tekst) }

  // .detalj { margin-bottom: 16px = 12pt }
  // .detaljtittel { font-size: 16px = 12pt; font-weight: 600 }
  // .detaljtekst { font-size: 16px = 12pt }
  block(below: 12pt)[
    #text(weight: "semibold", size: 12pt)[#tittel]
    #linebreak()
    #if stil == "LENKE" [
      // .LENKE { color: blue; text-decoration: underline }
      #text(fill: blue, size: 12pt)[#underline[#tekst-str]]
    ] else [
      #text(size: 12pt)[#breaklines(tekst-str)]
    ]
  ]
}

// Renders a single aktivitet card.
// aktivitet: the aktivitet object
// navn: the bruker's name (passed down to render-meldinger)
#let render-aktivitet(aktivitet, navn) = {
  let etiketter = aktivitet.at("etiketter", default: ())
  let fho = aktivitet.at("forhaandsorientering", default: none)
  let detaljer = aktivitet.at("detaljer", default: ())
  let eksterneHandlinger = aktivitet.at("eksterneHandlinger", default: ())
  let dialogtråd = aktivitet.at("dialogtråd", default: none)
  let historikk = aktivitet.at("historikk", default: none)

  // Show "Ulest" badge when forhaandsorientering exists but has not been read
  let show-ulest = fho != none and fho.at("tidspunktLest", default: none) == none

  // .aktivitet { border: 2px solid #838c9a; padding: 16px = 12pt; margin-bottom: 1rem = 9pt; border-radius: 4px }
  block(
    width: 100%,
    stroke: 2pt + rgb("#838c9a"),
    inset: 12pt,
    radius: 3pt,
    below: 9pt,
  )[
    // Top row: type (left) + badges (right).
    // Mirrors the CSS float:right on .etiketter and the following .type/.tittel.
    #grid(
      columns: (1fr, auto),
      column-gutter: 8pt,
      align: (left + top, right + top),
      // Left: type label (uppercase, small) and activity title
      [
        // .type { text-transform: uppercase; font-size: 14px = 10.5pt }
        #text(size: 10.5pt)[#upper(aktivitet.at("type", default: ""))]
        #v(8pt, weak: true)
        // h2.tittel { font-size: 24px = 18pt; font-weight: bolder }
        #text(size: 18pt, weight: "bold")[#aktivitet.at("tittel", default: "")]
      ],
      // Right: colored label badges
      [
        #for e in etiketter {
          render-etikett(e)
          h(2pt)
        }
        #if show-ulest {
          // .etikett-ulest { border: 1px solid #ff9100; background-color: #ff9100 } + white text
          box(
            fill: rgb("#ff9100"),
            stroke: 1pt + rgb("#ff9100"),
            inset: (left: 6pt, right: 6pt, top: 3pt, bottom: 5pt),
          )[
            #text(size: 10.5pt, fill: white)[Ulest]
          ]
        }
      ],
    )

    // Forhaandsorientering box (if present)
    #v(6pt)
    #render-forhaandsorientering(fho)

    // Detaljer: render HALV_LINJE pairs side-by-side, all others full-width.
    #{
      let i = 0
      let n = detaljer.len()
      while i < n {
        let d = detaljer.at(i)
        if (
          d.at("stil", default: "") == "HALV_LINJE"
          and i + 1 < n
          and detaljer.at(i + 1).at("stil", default: "") == "HALV_LINJE"
        ) {
          let d2 = detaljer.at(i + 1)
          // .HALV_LINJE { float: left; width: 50% } — rendered as a two-column grid
          grid(
            columns: (1fr, 1fr),
            column-gutter: 8pt,
            row-gutter: 8pt,
            render-detalj(d),
            render-detalj(d2),
          )
          i = i + 2
        } else {
          render-detalj(d)
          i = i + 1
        }
      }
    }

    // External action links (eksterneHandlinger)
    #for handling in eksterneHandlinger {
      // .eksternLenke { border: 0.5px solid black; padding: 16px = 12pt; border-radius: 2px; margin-bottom: 1rem }
      block(
        width: 100%,
        stroke: 0.5pt + black,
        inset: 12pt,
        radius: 1.5pt,
        below: 9pt,
      )[
        #grid(
          columns: (1fr, auto),
          align: (left + horizon, right + horizon),
          // .eksternlenkeTekstTittel { font-size: 20px = 15pt; font-weight: 600 }
          [
            #text(size: 15pt, weight: "semibold")[#handling.at("tekst", default: "")]
            #if handling.at("subtekst", default: none) != none [
              // .eksternLenkeSubTekst { font-size: 18px = 13.5pt }
              #linebreak()
              #text(size: 13.5pt)[#handling.at("subtekst", default: "")]
            ]
          ],
          // Right-pointing arrow icon (.eksternlenkeIkon, position: absolute right)
          text(size: 15pt)[→],
        )
      ]
    }

    // Dialog section (linked dialog thread on the aktivitet)
    #if dialogtråd != none {
      // .meldinger { border-top: 1px solid #cbcfd5; margin-bottom: 1.5rem }
      block(
        width: 100%,
        above: 0pt,
        below: 0pt,
        inset: (top: 6pt),
        stroke: (top: 1pt + rgb("#cbcfd5")),
      )[
        // .dialogOverskrift { margin-bottom: 8px; margin-top: 16px }
        // .h5 { font-size: 20px = 15pt; font-weight: 600 }
        #block(above: 20pt, below: 6pt)[
          // Chat-bubble icon approximated with Unicode
          #text(size: 13pt)[💬] #h(2pt)
          #text(size: 15pt, weight: "semibold")[Dialog]
        ]
        #render-meldinger(dialogtråd, navn)
      ]
    }

    // Historikk section
    #if historikk != none and historikk.at("endringer", default: ()).len() > 0 {
      // .historikk { border-top: 1px solid #cbcfd5; margin-bottom: 1.5rem }
      block(
        width: 100%,
        above: 0pt,
        below: pt,
        inset: (top: 6pt),
        stroke: (top: 1pt + rgb("#cbcfd5")),
      )[
        // .historikkOverskrift { margin-bottom: 8px; margin-top: 16px }
        #block(above: 16pt, below: 12pt)[
          // Clock icon approximated with Unicode
          #text(size: 13pt)[🕐] #h(2pt)
          #text(size: 15pt, weight: "semibold")[Historikk]
        ]
        #render-historikk(aktivitet)
      ]
    }
  ]
}
