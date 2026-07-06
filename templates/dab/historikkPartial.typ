// Renders the historikk (change history) section of an aktivitet.
// aktivitet: the full aktivitet object containing historikk.endringer
#let render-historikk(aktivitet) = {
  let historikk = aktivitet.at("historikk", default: none)
  if historikk == none { return }

  let endringer = historikk.at("endringer", default: ())
  if endringer.len() == 0 { return }

  let breaklines(t) = {
    if t == none or str(t) == "null" { return [] }
    let parts = str(t).split("\n")
    for (i, p) in parts.enumerate() {
      p
      if i < parts.len() - 1 { linebreak() }
    }
  }

  // .historikkHendelse { margin-top: 8px }
  for endring in endringer {
    block(above: 12pt, below: 0pt, inset: (top: 6pt, bottom: 6pt))[
      #text(weight: "semibold")[#endring.at("formattertTidspunkt", default: "")]
      #linebreak()
      #breaklines(endring.at("beskrivelse", default: ""))
    ]
  }
}
