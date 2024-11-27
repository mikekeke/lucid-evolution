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
#set text(15pt); Fine-tuning and Optimization ]

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
Documentation or reports showcasing the fine-tuning and optimization efforts applied to SanchoNet features for improved performance

#pagebreak()

#v(35pt)
= Optimizations
#v(15pt)
We made further enhancements to our governance-related endpoints and made sure they are all live and functioning with each of our releases on the Cardano Network for developers to utilize. 

We've implemented a range of DRep (Delegate Representative) operations, including registration, deregistration, and updates. Added support for various voting delegation scenarios, including "Always Abstain" and "Always No Confidence" options.

Made convenience functions to streamline functions that allow users to register and delegate in a single transaction and the extended TxBuilder including governance-specific methods, to enabling creation of highly efficient governance era transactions.

After our implementations we took a look back at how our Transaction builder (`TxBuilder`) was functioning and made iterative design choices to increase performance in all our endpoints.

#v(35pt)
== How?

By strategically making IO-bound computations optional by allowing preset protocol parameters during Lucid initialization and preset wallet UTXOs during transaction building.
As a result of this design choice we can increase the quality of UX for Cardano Governance era - where all of us are most focused at the moment. This will be followed by more deep dives into how we can make the library smoother and easier to use for all developers on Cardano and will be reinforced with further optimizations as we progress into the governance era and the needs of the developers evolve with it

*To not crowd this report with big code blocks* (>300 lines of code), we present the change  between these two states of the evolution library governance endpoints directly visible in our *GitHub repository*:

- #link("https://github.com/Anastasia-Labs/lucid-evolution/blob/main/packages/lucid/test/specs/governance-unoptimized.ts")[Previous version (Unoptimized)]

- #link("https://github.com/Anastasia-Labs/lucid-evolution/blob/main/packages/lucid/test/specs/governance-optimized.ts")[Newest version (Optimized)]

OR

- #link("https://github.com/Anastasia-Labs/lucid-evolution/pull/383")[Dedicated PR for Optimization]

The results of the optimizations have yielded an enormous reduction in our build times for transactions using governance endpoints of our library which you can see more about in the next report section "Performance Benchmarks"