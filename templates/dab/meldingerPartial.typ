// Renders the messages (meldinger) in a dialog thread.
// dialogtråd: the dialog object with meldinger array
// navn: the bruker's name (used for messages sent by BRUKER)
#let render-meldinger(dialogtråd, navn) = {
  if dialogtråd == none { return }

  let meldinger = dialogtråd.at("meldinger", default: ())
  let index-sist-lest = dialogtråd.at("indexSisteMeldingLestAvBruker", default: none)
  let tidspunkt-sist-lest = dialogtråd.at("tidspunktSistLestAvBruker", default: none)

  let breaklines(t) = {
    if t == none or str(t) == "null" { return [] }
    let parts = str(t).split("\n")
    for (i, p) in parts.enumerate() {
      p
      if i < parts.len() - 1 { linebreak() }
    }
  }

  for (i, melding) in meldinger.enumerate() {
    let is-bruker = melding.at("avsender", default: "") == "BRUKER"
    let avsender-navn = if is-bruker { navn } else { "NAV" }

    // .melding-BRUKER has margin-left: 32px = 24pt
    // 6pt left inset creates a gap between the border and the text content
    let chat-bubble = block(
      radius: 4pt,
      fill: if is-bruker { rgb(216, 249, 255) } else { luma(230) },
      inset: 6pt,
      above: 14pt,
      below: 0pt,
      width: 100%
    )[
      #text(weight: "semibold")[
        #avsender-navn - #melding.at("sendt", default: "")
      ]
      #parbreak()
      #breaklines(melding.at("tekst", default: ""))
    ]

    let left = if is-bruker { [] } else { chat-bubble }
    let right = if is-bruker { chat-bubble } else { [] }

    grid(
      columns: if is-bruker { (1fr, 4fr) } else { (4fr, 1fr) },
      gutter: 0pt,
      left,
      right,
    )

    // After the message at indexSisteMeldingLestAvBruker, show the "sist lest" indicator
    if index-sist-lest != none and index-sist-lest == i {
      block(above: 6pt, below: 0pt, inset: (left: 12pt))[
        #text(size: 10.5pt, style: "italic")[
          #sym.arrow.t #h(1pt) Lest av bruker #tidspunkt-sist-lest
        ]
      ]
    }
  }
}
