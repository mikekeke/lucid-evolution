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
#set text(15pt); Bug Identification and Resolution ]

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

Document with records of bug resolution activities, including bug fixes implemented, code changes made, and testing/validation of fixes.Verification reports confirming the successful resolution of identified bugs or issues

= Governance Era Bugs and our experience

At Anastasia Labs, we maintain an active presence in our Discord channel, where we engage daily with Cardano developers to address their challenges and concerns with Lucid Evolution. This direct communication channel has proven invaluable in identifying and resolving issues in real-time, ensuring that our library continues to meet the diverse needs of the ecosystem's developers.

During the critical transition period of the first hard fork, we provided extensive support to numerous dApps and individual developers, helping them adapt their applications to maintain compatibility and functionality which has helped us ourselves to identify further issues we have not encountered ourselves too. This hands-on approach demonstrates our commitment to not just developing tools, but actively supporting the broader Cardano developer community through significant protocol changes.

= Bug Tracking and Issues
We deliberately address all outstanding issues via our #link("https://github.com/Anastasia-Labs/lucid-evolution/issues?q=is%3Aissue+is%3Aclosed")[Issues section] of our repository. As it can be observed we have investigated and closed over 50+ issues to date, each of them containing varying depths of complexity. Our solutions and discussion for each of these issues can be tracked by anyone through the Issues section. We are continiously working on making the evolution library better, faster and smoother thanks to our team and active developer community.

#pagebreak()

#v(25pt)
= Bug Identification and Resolution
== Bug Resolution Activities
During our development cycle, we identified and resolved several issues through major pull requests for example (#link("https://github.com/Anastasia-Labs/lucid-evolution/pull/195")[PR 195], #link("https://github.com/Anastasia-Labs/lucid-evolution/pull/225")[PR 225]). 

*Technical Infrastructure*

A significant portion of our bug fixes addressed core infrastructure challenges. 

We implemented precise reference script fee calculations for the Conway era, including fixes like script size calculations that involved CBOR length handling. (Cost model JSON parsing improvements) 

Increased network compatibility by implementing specific feature handling between Preview and Preprod networks for consistent behavior across different environments.

*Performance and Reliability* 

For improved system reliability, we implemented Blockfrost rate limit handling and refined our dependency injection system.

The introduction of custom fee calculation capabilities through `setMinFee` provided more flexible transaction handling. 

These improvements were complemented by transaction builder issues/refinements that enhanced general performance and tackled `TxBuilder` issues.

*Technical Debt and Code Quality* 

Our quality assurance efforts included updating the Cardano Multiplatform Library (CML) to version 5.3.1-3 and implementing more robust error handling through `Effect.orDie`.

Our documentation improvements included the addition of sample environment configuration files and enhanced error messaging, making the library more accessible to developers. We have an integrated changeset for better version management.

== Ongoing Development
The governance features in Lucid Evolution are in a state of continuous development and refinement. As the Conway era and its associated governance mechanisms continue to evolve, our library adapts to keep pace with the latest community discussions and protocol changes.

Our codebase is designed to be easily adaptable to changes in the governance protocol. We maintain an extensive suite of on-chain tests to ensure reliability across different scenarios, while closely following constitutional workshops and governing body elections to align our features with the community's needs.
