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
#align(center)[#strong[Proof of Achievement - Milestone 5]\
#set text(15pt); CML Report ]

#v(5.5cm)

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
    #align(center)[*Anastasia Labs* \ Lucid-Evolution Milestone 5]
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
    #align(center)[*Anastasia Labs* \ Lucid-Evolution Milestone 5]
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

Provided documentation detaling Lucid Evolution aligns seamlessly with the latest advancements in Cardano's CML is available at https://github.com/Anastasia-Labs/lucid-evolution




#pagebreak()
#v(35pt)
= CML Integration and Lucid Evolution
#v(35pt)
== Context

Lucid Evolution's relationship with Cardano Multiplatform Library (CML) began with addressing fundamental challenges in transaction processing and memory management. Our initial contributions focused on resolving memory leaks and optimizing WASM builds for JavaScript interfaces, as evidenced in our early work with CML's memory management systems #link("https://github.com/dcSpark/cardano-multiplatform-lib/pull/182")[documented here].

== Current State of Integration

Today, Lucid Evolution maintains a sophisticated fork of CML (anastasia-labs/cardano-multiplatform-lib v6.0.2-2) that extends beyond the current mainline CML version (6.0.1). This advancement isn't about version numbers – it represents our commitment to pushing the boundaries of what's possible with Cardano's off-chain operations. 

Our fork incorporates features and optimizations that anticipate future network requirements, as CML repository naturally takes a longer time to make new releases.

#pagebreak()
#v(35pt)
== Technical Contributions

Our team has been active in implementing updates for the upcoming hardfork. A example is our work on set tag serialization, where we've developed a solution that address both current and future protocol requirements. The implementation of the 258 tag serialization requirement showcases our approach:

```
impl<T: Serialize> Serialize for NonemptySet<T> {
    fn serialize<'se, W: Write>(
        &self,
        serializer: &'se mut Serializer<W>,
        force_canonical: bool,
    ) -> cbor_event::Result<&'se mut Serializer<W>> {
        if let Some(tag_encoding) = &self.tag_encoding {
            serializer.write_tag_sz(258,*tag_encoding)?;
        }
        serializer.write_array_sz(
            self.len_encoding
                .to_len_sz(self.elems.len() as u64, force_canonical),
        )?;
        // Implementation continues...
    }
}
```

We are committed to maintaining backward compatibility while preparing for future protocol changes.

#pagebreak()
#v(35pt)
== Memory Management and Performance Optimization

Building on our earlier contributions to memory management in CML, we've continued to refine and enhance these systems. Our implementation includes UTXO management that enables efficient #link("https://github.com/Anastasia-Labs/lucid-evolution/pull/141/commits")[chaining of transactions] within a single block. These improvements have been important in minimizing memory leaks and enhancing stability, particularly in WASM

== Cross-Network Compatibility and Future-Proofing
Our implementation ensures seamless operation across all Cardano network environments. This includes current mainnet protocols, preview/testnet features, and upcoming hardfork requirements. Diagnostic notation of our serialization shows this compatibility:

``` 
{
    0: 258_1([
        [
h'f9aa3fccb7fe539e471188ccc9ee65514c5961c070b06ca185962484a4813bee',
h'8e782b6a21fbe1361c6220bea7d1327fd8c3d6c1f0d34361193f7a98a5609e6dca
08e10c3dc291b746c26018721c786ecc3753c5318458d7da4cc61ef0f97f05'
        ]
    ])
}
```

#pagebreak()
#v(35pt)
== Active Development

Our team maintains engagement with the CML development community, as evidenced by our recent contributions to discussions about serialization requirements and protocol updates.

== References to our work and further evidence
=== Repositories

- Cardano Multiplatform Library (CML) Main Repository: #link("https://github.com/dcSpark/cardano-multiplatform-lib")[github.com/dcSpark/cardano-multiplatform-lib]

- Lucid Evolution Repository: #link("https://github.com/Anastasia-Labs/lucid-evolution")[github.com/Anastasia-Labs/lucid-evolution]

- Our Custom CML Fork: #link("https://github.com/Anastasia-Labs/cardano-multiplatform-lib")[github.com/Anastasia-Labs/cardano-multiplatform-lib]

=== CML / Lucid Evolution Interactions

- Set Tag Serialization Discussion: #link("https://github.com/dcSpark/cardano-multiplatform-lib/issues/364")[Issue #364]
- Implementation PR: #link("https://github.com/dcSpark/cardano-multiplatform-lib/pull/365")[PR #365]
- Commit Reference: #link("https://github.com/dcSpark/cardano-multiplatform-lib/pull/365/commits/b1bedaffa3eff486e5ed0e1c64701dec21d13570")[b1bedaff]

=== Memory Management Improvements

- Memory Leak Resolution: #link("https://github.com/dcSpark/cardano-multiplatform-lib/pull/182")[CML PR #182]
- Transaction Chaining Implementation: #link("https://github.com/Anastasia-Labs/lucid-evolution/pull/141")[PR #141]