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
#set text(15pt); Test Execution Results ]

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

Test execution reports documenting the results of testing, including pass/fail status, identified issues, and any necessary follow-up actions taken

#pagebreak()
#v(35pt)
= Test Execution Results
#v(15pt)
Our tests involve executing >100 CI tests against the latest updated state with every update we push. *All test cases run directly on the Cardano preprod and preview networks.* For a better understanding please refer to our repository directly, specifically the test cases:

- #link("https://github.com/Anastasia-Labs/lucid-evolution/blob/main/packages/lucid/test/onchain-preprod.test.ts")[`onchain-preprod.test.ts`]

- #link("https://github.com/Anastasia-Labs/lucid-evolution/blob/main/packages/lucid/test/onchain-preview.test.ts")[`onchain-preview.test.ts`]


In our tests we cover different domains of operations:

*Transaction Building* Tests validate basic and complex transaction construction, including multi-asset handling and metadata integration. Our transaction chaining tests requiring that dependent transactions execute correctly in sequence.

*Stake Operations* Testing of stake registration, delegation, and rewards. This includes native staking operations and complex scenarios involving multiple validators.

=== Conway Era Features
Full coverage of new governance endpoints, including DRep registration, voting delegation, and combinations of pool and DRep delegation scenarios.

*Multi-Validator Operations* Tests that verify complex interactions between different validator scripts

*Asset Management* several different operations for native assets, including minting, burning, and transfer scenarios, with proper verification of token policies.

As part of our CI pipeline, these tests run regularly, ensuring ongoing compatibility and reliability with each new version of `lucid-evolution`. Each test execution validates not just the success of operations, but also proper resource management through UTxO recycling and optimization.

So everytime we are updating our library we ensure that we can meet the demands of our testing suite to have a reference of secure design

#pagebreak()
#v(35pt)
= Library test
Example test execution of all our tests in our testing suite passing (from `onchain-preprod.test.ts`):


#align(center)[== Video Material

#link("https://x.com/solidsnakedev/status/1846633770964996590")[Succesful Library check]
]

#v(15pt)
= Governance Endpoints Test
#v(15pt)

To ensure consistency across different Cardano environments, we run our test suite on both the Preview and Preprod networks:

- `packages/lucid/test/onchain-preview.test.ts`

- `packages/lucid/test/onchain-preprod.test.ts`

#v(15pt)
#align(center)[== GIF Testrun

#link("https://github.com/Anastasia-Labs/lucid-evolution/blob/main/assets/images/governance.gif")[Succesful Governance Test ]
\
\

This GIF, *a onchain test* running in terminal,
showcases \ that our test packages are working as intended by displaying succesfully executed test cases

]