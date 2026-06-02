#import "/templates/dab/aktivitetPartial.typ": render-aktivitet
#import "/templates/dab/meldingerPartial.typ": render-meldinger

// JSON data injected by pdfgenrs at /data.json
#let data = json("/data/dab/aktivitetsplan.json")

// ─── Page setup ──────────────────────────────────────────────────────────────
// @page margins: right/left 80px, top/bottom 77px (1px = 0.75pt at 96 dpi)
#set page(
  paper: "a4",
  margin: (left: 60pt, right: 60pt, top: 57.75pt, bottom: 57.75pt),
  footer: context [
    // #footer { font-size: 12px = 9pt; float: right for page number }
    #set text(size: 9pt)
    #align(right)[
      Side #counter(page).display() av #counter(page).final().first()
    ]
  ],
)

// ─── Typography ──────────────────────────────────────────────────────────────
#set text(font: "Source Sans Pro", fill: rgb("#262626"), size: 12pt)

// Suppress default paragraph leading so spacing is controlled explicitly
#set par(leading: 0.65em)

// ─── Helper functions ────────────────────────────────────────────────────────

// Converts newlines in text to Typst linebreaks; handles none/"null" gracefully.
#let breaklines(t) = {
  if t == none or str(t) == "null" { return [] }
  let parts = str(t).split("\n")
  for (i, p) in parts.enumerate() {
    p
    if i < parts.len() - 1 { linebreak() }
  }
}

// Section heading matching h3 { font-size: 28px = 21pt; font-weight: 500; margin-bottom: 8px }
#let h3(content) = block(
  above: 18pt,
  below: 6pt,
)[
  #text(size: 21pt, weight: "medium")[#content]
]

// ─── NAV logo ────────────────────────────────────────────────────────────────
// .header-ikon { width: 20%; margin: 0 auto } — centered, 20% of content width
#align(center)[
  #image("/resources/NavLogoRed.svg", width: 20%, alt: "NAV logo")
]

// ─── Document header ─────────────────────────────────────────────────────────
// .header { margin-bottom: 4rem = 48pt; margin-top: 4rem = 48pt }
// .personinfo { float: left; width: 50% }
// .dato-enhet { float: right; width: 50%; text-align: right }
#block(above: 48pt, below: 48pt)[
  #grid(
    columns: (1fr, 1fr),
    align: (left + top, right + top),
    [
      *#data.at("navn", default: "")*
      #linebreak()
      F.nr: #data.at("fnr", default: "")
    ],
    [
      #data.at("journalførendeEnhetNavn", default: "")
      #linebreak()
      #data.at("dagensDato", default: "")
    ],
  )
]

// ─── Filters or period description ───────────────────────────────────────────
#let brukteFiltre = data.at("brukteFiltre", default: none)

#if brukteFiltre != none and type(brukteFiltre) == dictionary and brukteFiltre.len() > 0 {
  // Render each active filter category with chip-style values
  for (key, values) in brukteFiltre {
    block(below: 6pt)[
      #key: #for v in values {
        // .valgt-filter { border: 1px solid #949292; background-color: #cecece; border-radius: 4px;
        //   padding: 1px 6px 3px 6px; font-size: 14px = 10.5pt; margin-right: 8px }
        box(
          fill: rgb("#cecece"),
          stroke: 1pt + rgb("#949292"),
          radius: 3pt,
          inset: (left: 4.5pt, right: 4.5pt, top: 0.75pt, bottom: 2.25pt),
        )[
          #text(size: 10.5pt)[#v]
        ]
        h(6pt)
      }
    ]
  }
} else {
  // No filters: show period description paragraph
  let periode-start = data.at("oppfølgingsperiodeStart", default: "")
  let periode-slutt = data.at("oppfølgingsperiodeSlutt", default: none)
  let journaltidspunkt = data.at("journalfoeringstidspunkt", default: "")

  par[
    #if periode-slutt != none [
      Dette dokumentet viser et øyeblikksbilde av hvordan aktivitetsplanen og dialogen var
      #journaltidspunkt for oppfølgingsperioden som startet #periode-start og som ble avsluttet
      #periode-slutt.
    ] else [
      Dette dokumentet viser et øyeblikksbilde av hvordan aktivitetsplanen og dialogen var
      #journaltidspunkt for oppfølgingsperioden som startet #periode-start.
    ]
  ]
}

// ─── Mitt mål ─────────────────────────────────────────────────────────────────
#let maal = data.at("mål", default: none)
#if maal != none and str(maal) != "" {
  h3[Mitt mål]
  par[#maal]
}

// ─── Activity groups ──────────────────────────────────────────────────────────
#let aktiviteter = data.at("aktiviteter", default: (:))
#let navn = data.at("navn", default: "")

// Foreslåtte aktiviteter
#let forslag = aktiviteter.at("Forslag", default: ())
#if forslag.len() > 0 {
  h3[Foreslåtte aktiviteter]
  for a in forslag {
    render-aktivitet(a, navn)
  }
}

// Planlagte aktiviteter
#let planlagt = aktiviteter.at("Planlagt", default: ())
#if planlagt.len() > 0 {
  h3[Planlagte aktiviteter]
  for a in planlagt {
    render-aktivitet(a, navn)
  }
}

// Aktiviteter som gjennomføres nå
#let gjennomfores = aktiviteter.at("Gjennomføres", default: ())
#if gjennomfores.len() > 0 {
  h3[Aktiviteter som gjennomføres nå]
  for a in gjennomfores {
    render-aktivitet(a, navn)
  }
}

// Fullførte aktiviteter
#let fullfort = aktiviteter.at("Fullført", default: ())
#if fullfort.len() > 0 {
  h3[Fullførte aktiviteter]
  for a in fullfort {
    render-aktivitet(a, navn)
  }
}

// Avbrutte aktiviteter
#let avbrutt = aktiviteter.at("Avbrutt", default: ())
#if avbrutt.len() > 0 {
  h3[Avbrutte aktiviteter]
  for a in avbrutt {
    render-aktivitet(a, navn)
  }
}

// ─── Dialogen med veileder ────────────────────────────────────────────────────
#let dialogtråder = data.at("dialogtråder", default: ())
#if dialogtråder.len() > 0 {
  h3[Dialogen med veileder]
  for tråd in dialogtråder {
    // .dialogtråd { border: 2px solid #838c9a; padding: 16px = 12pt; margin-bottom: 1rem; border-radius: 4px }
    block(
      width: 100%,
      stroke: 2pt + rgb("#838c9a"),
      inset: 12pt,
      radius: 3pt,
      below: 9pt,
    )[
      // .dialogtrådOverskrift { font-size: 24px = 18pt; font-weight: 600 }
      #text(size: 18pt, weight: "semibold")[#tråd.at("overskrift", default: "")]
      #render-meldinger(tråd, navn)
    ]
  }
}
