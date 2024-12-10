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
#align(center)[#strong[Lucid Evolution]\
#set text(15pt); Project Close-out Report\ Fund 11: Cardano Open - Developers]

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









#v(65pt)

= Introduction
#v(15pt)
Lucid Evolution represents a significant milestone in Cardano's developer ecosystem, emerging as a complete reimagining of the original Lucid library for off-chain operations. This project, spanning from October 2023 to March 2024, has transformed from a simple library migration into a cornerstone of Cardano's development infrastructure.

Our mission was to address critical challenges in the ecosystem:
- The need for modern, type-safe transaction building
- Support for Conway era governance features
- Enhanced provider implementations
- Comprehensive testing and documentation

Through six months of intensive development, we've delivered:

- A complete rewrite of the legacy library using modern best practices in accordance to the needs of Cardano off-chain development and addressing key issues developers face everyday
- Integration with 20+ major Cardano projects
- Support for multiple provider implementations
- Extensive documentation and testing suites


What sets Lucid Evolution apart is its commitment to developer experience without compromising on performance. The library maintains backward compatibility while introducing modern features, making it easier for developers to build complex applications on Cardano.

This close-out report is an attempt to briefly showcase our journey, achievements, and the impact Lucid Evolution has had on the Cardano ecosystem.






#pagebreak()
#v(35pt)
= Challenge KPIs and Achievements
#v(15pt)
== Developer Ecosystem Growth
- 1050+ commits, 435+ releases, demonstrating active development
- 55+ closed issues, 345+ closed pull requests showing community engagement

#v(35pt)
== Technical Implementation
Lucid Evolution represents a complete rewrite of the legacy Lucid library, built with modern TypeScript architecture and enhanced type safety. 

*Core Architecture Modernization*
A ground-up rebuild utilizing functional programming patterns, with significant improvements in memory management and error handling. This modern foundation ensures better maintainability and extensibility for future Cardano features.

*Conway Era Governance Features*
Implementation of comprehensive governance capabilities including action building, committee management, DRep registration, and voting mechanisms.

*Provider Infrastructure*
Development of diverse provider implementations including Blockfrost, Kupmios (hybrid Ogmios/Kupo solution), Maestro, and Koios (decentralized querying). Each provider maintains a common interface, allowing easy switching between the options while leveraging provider-specific optimizations.

*Testing and Documentation*
Establishment of a comprehensive testing suite covering unit tests (utilities, helpers), integration tests (transaction building), contract interaction tests, and provider-specific validations. The automated CI/CD pipeline ensures reliability through onchain preview and preproduction testing. All features are documented in our interactive documentation portal (https://anastasia-labs.github.io/lucid-evolution/), providing developers with clear guides and examples.

#pagebreak()
#v(25pt)
= Project-Specific KPIs
#v(15pt)
#box(height: 260pt,
  stroke: none,
  columns(2, gutter: 21pt)[
== Library Development
- Memory leak fixes and performance optimizations
- Transaction builder improvements
- Refined fee calculation capabilities
- Cross-platform compatibility

== Community Engagement
- Active Discord support channel
- Real-time developer assistance during hard fork transitions
- Collaborative bug resolution process
- Regular community feedback integration

= Key Achievements

== Technical Milestones
1. Successful transition from legacy Lucid
2. Implementation of Conway era features
3. Enhanced transaction composition
4. More diverse provider integrations

== Collaboration & Engagement
- Partnership with major Cardano projects
- Community-driven development approach
- Open-source contribution framework
])

#v(15pt)
= Key Learnings
#v(15pt)
- Importance of backward compatibility
- Value of community feedback in development
- Need for comprehensive testing
- Balance between innovation and stability
- Significance of documentation quality


#pagebreak()
#v(35pt)
== Major Protocol Integrations
#v(35pt)
#box(height: 280pt,
  stroke: none,
  columns(2, gutter: 21pt)[
=== Infrastructure
- *Cardano Foundation - IBC*: Integration for cross-chain communication infrastructure
- *EMURGO Academy*: Educational integration for developer training
- *Midgard Protocol*: Cardano L2
- *Maestro*: Infrastructure provider integration for enhanced scalability

=== DeFi Protocols
- *Liqwid Finance*: Lending / Borrowing
- *Splash*: DEX protocol 
- *Meld*: Banking / DeFi protocol
- *WingRiders*: DEX protocol
- *Genius Yield*: DEX / Yield optimization protocol 
- *Strike Finance*: Derivatives protocol
- *Summon*: DAO tooling

=== Wallet Integrations
- *VESPR Wallet*: Full wallet integration 
- *Fetch*: DEX Aggregator

=== Analytics and Tools
- *Atrium*: Community platform
- *Cardexscan*: Block explorer 
- *Mynth*: Cross-chain bridge / DEX
- *Pondora*: All in one DeFi platform 

=== Emerging Projects
- *GenWealth*
- *BettingADA*
])


#pagebreak()

#v(25pt)
= Relevant Links
- GitHub Repository: #link("https://github.com/Anastasia-Labs/lucid-evolution")
- Documentation: #link("https://anastasia-labs.github.io/lucid-evolution/")
- Discord Community: #link("https://discord.com/invite/s89P9gpEff")
- NPM Package: #link("https://www.npmjs.com/package/@lucid-evolution/lucid")

#v(25pt)
= Next Steps
#v(25pt)
1. Further Conway era feature development
2. Keeping up-to-date with new Cardano primitives that are introduced
3. Increasing the variety of provider implementations
4. Further performance optimization to support needs of highly scalable dApps
5. Continued community support and engagement
6. Make Lucid Evolution into a full blown SDK for Cardano developers in the future

Our main target is and always will be to reach a wider developer audience and make Lucid Evolution one of the only tools you would need to finish your development tasks.

#v(35pt)
= Final Thoughts
#v(15pt)
Lucid Evolution has successfully transformed from a library migration project into a cornerstone of Cardano's developer ecosystem, providing essential tools for off-chain operations while keeping high standards of reliability and performance.



#v(25pt)
#align(center)[== Close-out Video <link-other>
- #link("https://youtu.be/PFe5cHuQ8oM?si=YUdaW9wjYZ__0aFR")[Youtube]]