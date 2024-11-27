// Set the background image for the page
#let image-background = image("images/Background-Carbon-Anastasia-Labs-01.jpg", height: 100%)
#set page(
  background: image-background,
  paper: "a4",
  margin: (left: 20mm, right: 20mm, top: 40mm, bottom: 30mm)
)

// Set default text style
#set text(22pt, font: "Barlow")
#set par(justify: true)
#v(3cm) // Add vertical space

// Center-align the logo
#align(center)[#box(width: 75%, image("images/Logo-Anastasia-Labs-V-Color02.png"))]

#v(1cm)

// Set text style for the report title
#set text(20pt, fill: white)

// Center-align the report title
#align(center)[#strong[Proof of Achievement - Milestone 4]\
#set text(15pt); Keeping Pace with Cardano Evolution ]

#v(6cm)

// Set text style for project details
#set text(13pt, fill: white)

// Display project details
#table(
  columns: 2,
  stroke: none,
  [*Project Number*], [1100024],
  [*Project Manager*], [Jonathan Rodriguez],
 
)

// Reset text style to default
#set text(fill: luma(0%))

// Configure the initial page layout
#set page(
  background: none,
  header: [
    // Place the logo in the header
    #place(right, dy: 12pt)[#box(image(height: 75%,"images/Logo-Anastasia-Labs-V-Color01.png"))]
    #line(length: 100%) // Add a line under the header
  ],
  header-ascent: 5%,
  footer: [
    #set text(11pt)
    #line(length: 100%) // Add a line above the footer
    #align(center)[*Anastasia Labs* \ Lucid-Evolution Milestone 4]
  ],
  footer-descent: 20%
)
// #set par(justify: true)
#show link: underline
#show outline.entry.where(level: 1): it => {
  v(12pt, weak: true)
  strong(it)
}

// Initialize page counter
#counter(page).update(0)

#set page(
  footer: [
    #set text(11pt)
    #line(length: 100%) // Add a line above the footer
    #align(center)[*Anastasia Labs* \ Lucid-Evolution Milestone 4]
    #place(right, dy:-7pt)[#counter(page).display("1/1", both: true)]
  ]
)
#v(100pt)

// Configure the outline depth and indentation
#outline(depth:2, indent: 1em)

// Page break
#pagebreak()
#set terms(separator: [: ],hanging-indent: 40pt)
#v(20pt)
/ Project Name: Lucid Evolution: Redefining Off-Chain Transactions in Cardano
/ URL: #link("https://projectcatalyst.io/funds/11/cardano-open-developers/anastasia-labs-lucid-evolution-redefining-off-chain-transactions-in-cardano")[Catalyst Proposal]










// Raw Text settings `text`(Inline Code)
#show raw.where(block: false): box.with(
  fill: luma(230),
  inset: (x: 3pt, y: 0pt),
  outset: (y: 3pt),
  radius: 2pt,
)



// Setting default text config before content
#set text(12pt, font: "Barlow")
#show heading.where(level: 1): set text(rgb("#c41112"))
#show heading.where(level: 2): set text(rgb("#c41112"))
#show heading.where(level: 3): set text(rgb("#c41112"))



// Codeblock settings
#import "@preview/codly:0.1.0": codly-init, codly, disable-codly
#show: codly-init.with()
#codly(
  stroke-width: 0.6pt,
  stroke-color: red,
)






#v(110pt)
= Evidence Definition
#v(15pt)

Document with performance benchmark results comparing the optimized SanchoNet features with previous version (https://github.com/spacebudz/lucid/releases/tag/0.10.7) or benchmarks, demonstrating improvements achieved

#pagebreak()
#v(35pt)
= Performance Benchmark
#v(15pt)

Our #link("https://github.com/Anastasia-Labs/lucid-evolution/blob/main/packages/lucid/test/specs/governance-optimized.ts")[optimization efforts] seen in the previous report section have yielded remarkable improvements in governance operation execution times, achieving a maximum: *99.6%*, minimum: *99.1%* reduction in measured processing time across our governance endpoints

== Comparative Analysis
==== Previous Governance Endpoint

- registerDRep: 2234ms 
- updateDRep: 2161ms 
- deregisterDRep: 2261ms
- registerScriptDRep: 2198ms
- deregisterScriptDRep: 2195ms

==== Optimized Governance Endpoint

- registerDRep: Slashed from 2234ms to a mere 11ms *(-99.5%)*
- updateDRep: Improved from 2161ms to just 9ms *(-99.6%)*
- deregisterDRep: Enhanced from 2261ms to 9ms *(-99.6%)*
- registerScriptDRep: Reduced from 2198ms to 19ms *(-99.1%)*
- deregisterScriptDRep: Down from 2195ms to 19ms *(-99.1%)*

== Implementation Context

It's important to note that a direct comparison with the legacy Lucid library (version 0.10.7) is not possible, as governance features were not supported in that version. The performance metrics presented above demonstrate the improvement between our initial implementation and the current optimized state within the Lucid Evolution library.

#v(35pt)
== Visual Demonstration
For a visual representation of these performance improvements, you can view our 
#link("https://github.com/Anastasia-Labs/lucid-evolution/blob/main/assets/images/governance-benchmark.gif")[benchmark comparison demonstration]


