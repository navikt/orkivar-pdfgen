// Renders the forhaandsorientering (advance notice) box for an aktivitet.
// fho: the forhaandsorientering object, or none
#let render-forhaandsorientering(fho) = {
  if fho == none { return }

  // .forhaandsorientering { background: #FFECCC; border: 1px solid #C77300; border-radius: 4px;
  //                          padding: 16px 16px 4px 16px; margin-bottom: 16px }
  block(
    width: 100%,
    fill: rgb("#FFECCC"),
    stroke: 1pt + rgb("#C77300"),
    radius: 3pt,
    inset: (left: 12pt, right: 12pt, top: 12pt, bottom: 14pt),
    below: 16pt,
  )[
    // h4 { font-size: 22px = 16.5pt; font-weight: 500 }
    #text(size: 16.5pt, weight: "medium")[Informasjon om ansvaret ditt]
    #parbreak()
    #(fho.at("tekst", default: ""))
    #parbreak()
    #let lest = fho.at("tidspunktLest", default: none)
    #if lest != none [
      Lest av bruker: #lest
    ] else [
      // .forhaandsorientering-knapp { border: 2px solid #0067C5; border-radius: 4px;
      //   color: #0067C5; padding: 12px 20px; font-weight: 500; display: inline-block; margin-bottom: 12px }
      #block(above: 9pt, below: 9pt)[
        #box(
          stroke: 2pt + rgb("#0067C5"),
          radius: 3pt,
          inset: (left: 15pt, right: 15pt, top: 9pt, bottom: 9pt),
        )[
          #text(fill: rgb("#0067C5"), weight: "medium")[Ok, jeg har lest beskjeden]
        ]
      ]
    ]
  ]
}
