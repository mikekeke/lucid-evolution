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
#set text(15pt); Bug Resolution and Community Requests ]

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

Provided documentation of the steps taken to address each identified bug or issue, including code changes, patches, or updates implemented to resolve them is available


#pagebreak()
#v(35pt)
= Bug Resolution and Community Requests

#v(15pt)
Throughout the development of Lucid Evolution, we've addressed numerous bugs, issues, and community requests, as evidenced by:
- 1050+ commits
- 435+ releases
- 55+ *closed* issues
- 345+ *closed* pull requests

These can be verified in our repository where we keep track of all discussions that take place about and around lucid evolution. Even though our primary communication channel with the developer community is the dedicated Discord channel, we still refer everyone to use github issues and PRs to sustainably maintain our open source library.

While documenting every bug fix would be impractical for this report, we'll highlight several representative examples that demonstrate our approach to:

1. Bug fixes
2. Performance improvements
3. Community-requested features

== Links
=== Commits
https://github.com/Anastasia-Labs/lucid-evolution/commits/main/

=== Releases
https://github.com/Anastasia-Labs/lucid-evolution/releases

=== Github Issues
https://github.com/Anastasia-Labs/lucid-evolution/issues?q=is%3Aissue+is%3Aclosed

=== Pull Requests we handled
https://github.com/Anastasia-Labs/lucid-evolution/pulls?q=is%3Apr+is%3Aclosed


#pagebreak()
#v(35pt)
= Example: Fee Calculation for Reference Scripts

=== Context
During Conway era updates on Cardano, a issue emerged regarding fee calculations when spending UTXOs containing reference scripts. 

=== Challenge
- Transaction fees were being incorrectly calculated when spending UTXOs with attached reference scripts
- The issue became particularly relevant due to Conway era updates modifying fee structures
- Required careful consideration of both user experience and network rules

=== Technical Resolution
1. Identified that reference scripts now carry additional weight in fee calculations
2. Modified coin selection logic to handle reference script UTXOs differently
3. Implemented explicit fee handling for reference script transactions
4. Added testing to verify the solution

=== Impact for Developers
- More accurate fee estimation for transactions
- Improved handling of reference script UTXOs
- Better alignment with Conway era requirements

== Related Links
- Issue: #link("https://github.com/Anastasia-Labs/lucid-evolution/issues/223")[Fee calculation error #223]
- Fix PR: #link("https://github.com/Anastasia-Labs/lucid-evolution/pull/233")[Fix reference script fees issues #233]
- Related CML Update: #link("https://github.com/dcSpark/cardano-multiplatform-lib/pull/349")[dcSpark/cardano-multiplatform-lib#349]

#pagebreak()
#v(35pt)
= Example 2: Datum Handling Consistency in Contract Payments

=== Context
A compatibility issue was identified where datum handling behavior differed between Legacy Lucid and Lucid Evolution, potentially affecting dApp migrations and existing smart contract interactions.

=== Challenge
- Inconsistent datum inclusion behavior in witness sets between library versions
- Affected common `payToContract` operations with datum hashes
- Impacted developers migrating from legacy Lucid to Lucid Evolution
- Required maintaining backward compatibility while improving the codebase

=== Technical Resolution
1. Identified the behavioral difference in datum handling
2. Implemented automatic datum inclusion for `asHash` kind in payToContract operations
3. Released fix in version 0.3.10
4. Verified solution through community testing

=== Impact for Developers
- Consistent behavior with legacy Lucid library
- Simplified migration path for existing dApps
- Improved reliability in smart contract interactions
- Better backward compatibility

== Related Links
- Issue: #link("https://github.com/Anastasia-Labs/lucid-evolution/issues/227")[Inconsistent Datum Inclusion #227]
- Fix PR: #link("https://github.com/Anastasia-Labs/lucid-evolution/pull/228")[Fix datum inclusion for asHash kind #228]
- Migration Guide: #link("https://github.com/Anastasia-Labs/lucid-evolution/issues/189")[Migration guide from Lucid #189]
- Release: #link("https://github.com/Anastasia-Labs/lucid-evolution/releases/tag/0.3.10")[v0.3.10]

#pagebreak()
#v(35pt)
= Example 3: Wallet Fund Management and Transaction Fee Optimization

=== Context
VESPR Wallet team, during their migration to Lucid Evolution, identified a critical functionality gap in handling scenarios where users want to send all their ADA funds. This highlighted our library's role in supporting production wallets and maintaining compatibility with existing user experiences.

=== Challenge
- Users couldn't send all their ADA when remaining funds were insufficient for change UTxO
- Previous behavior in legacy Lucid automatically added remaining amount to transaction fee
- Required maintaining wallet draining functionality while ensuring precise transaction control
- Needed to support multiple wallet implementation scenarios

=== Technical Resolution
1. Implemented new configuration option `includeLeftoverLovelaceAsFee`
2. Added flexibility in handling remaining funds:
   - Option to throw error (default behavior)
   - Option to include leftover in transaction fee
3. Maintained backward compatibility with existing implementations
4. Verified solution through direct testing with VESPR wallet team

=== Impact for Developers
- Simplified wallet draining operations
- More control over transaction fee handling
- Better support for production wallet implementations
- Improved migration path from legacy Lucid

== Related Links
- Issue: #link("https://github.com/Anastasia-Labs/lucid-evolution/issues/368")[Wallet Fund Management #368]
- Fix PR: #link("https://github.com/Anastasia-Labs/lucid-evolution/pull/392")[Add option to include tiny change #392]
- Implementation: #link("https://github.com/Anastasia-Labs/lucid-evolution/blob/main/packages/lucid/src/tx-builder/TxBuilder.ts")[TxBuilder.ts]

#pagebreak()
#v(35pt)
= Example 4: Script Integrity Hash Validation

=== Context
A issue emerged where transactions using datum of kind "asHash" were failing with PPViewHashesDontMatch errors. Our library's deep integration with Cardano's protocol-level features and our coordination with other ecosystem tools have been shown through this example

=== Challenge
- Transactions with "asHash" datum type were failing validation
- Error specifically related to script integrity hashes
- Affected multiple versions (0.3.15 through 0.3.18)
- Required coordination with CML (Cardano Multiplatform Library) team

=== Technical Resolution
1. Identified root cause in script integrity hash calculation
2. Coordinated with dcSpark team on CML updates
3. Implemented fix through CML version bump
4. Verified solution across different transaction scenarios

=== Impact for Developers
- Restored reliable datum hash handling
- Conway era compatibility
- Transaction validation reliability
- Seamless integration with latest protocol features

== Related Links
- Issue: #link("https://github.com/Anastasia-Labs/lucid-evolution/issues/261")[Script Integrity Hash Issue #261]
- CML Fix: #link("https://github.com/dcSpark/cardano-multiplatform-lib/pull/351")[dcSpark/cardano-multiplatform-lib#351]
- Implementation: #link("https://github.com/Anastasia-Labs/lucid-evolution/pull/285")[Bump CML version #285]

#pagebreak()
#v(35pt)

= Example 5: Build System Enhancement for Developer Testing

=== Context
A community developer identified challenges in the build distribution structure that affected the testing workflow. This highlighted our commitment to improving developer experience and maintaining an efficient development cycle.

=== Challenge
- Build process distributed packages under complex file structures
- Developers faced difficulties in quickly testing new versions
- Needed streamlined process for local development and testing
- Required clear documentation for package management

=== Technical Resolution
1. Clarified build process documentation
2. Implemented package-specific build commands
3. Added support for quick testing via `pnpm pack`
4. Created streamlined workflow for local development:
   - Package-level building
   - Tarball generation
   - Local dependency integration

=== Impact for Developers
- Simplified local development workflow
- Faster testing cycles
- Clearer package management process
- Improved contribution experience

== Related Links
- Issue: #link("https://github.com/Anastasia-Labs/lucid-evolution/issues/140")[Build Distribution Structure #140]
- NPM Package: #link("https://www.npmjs.com/package/@lucid-evolution/lucid")[lucid-evolution/lucid]
- Test Directory: #link("https://github.com/Anastasia-Labs/lucid-evolution/tree/main/packages/lucid/test")[Test Examples]

#pagebreak()
#v(35pt)
= Example 6: Hardware Wallet Compatibility and CIP-21 Compliance

=== Context
A compatibility issue was identified with Trezor hardware wallet transactions, highlighting the importance of adhering to Cardano protocol standards (CIP-21) and maintaining broad hardware wallet support.

=== Challenge
- Transactions were failing specifically on Trezor hardware wallets
- Root cause identified as non-compliance with CIP-21 map ordering requirements
- Affected transactions with datums required special handling
- Needed solution compatible with hardware wallet security models

=== Technical Resolution
1. Implemented canonical format for transaction data structures
2. Added proper map ordering according to CIP-21 specifications
3. Enhanced compatibility with cardano-hw-cli transformations
4. Released fix in version 0.3.37 with comprehensive changes

=== Impact for Developers
- Improved hardware wallet support
- Better compliance with Cardano standards
- Enhanced transaction reliability
- Simplified hardware wallet integration

== Related Links
- Issue: #link("https://github.com/Anastasia-Labs/lucid-evolution/issues/196")[Hardware Wallet Compatibility #196]
- Fix PR: #link("https://github.com/Anastasia-Labs/lucid-evolution/pull/333")[Implement canonical format #333]
- CIP-21 Standard: #link("https://cips.cardano.org/cip/CIP-21")[Cardano Transaction Metadata Format]
- Release: #link("https://github.com/Anastasia-Labs/lucid-evolution/releases/tag/%40lucid-evolution%2Flucid%400.3.37")[v0.3.37]

#pagebreak()
#v(35pt)
= Example 7: Transaction Signer Flexibility

=== Context
The community identified a limitation in the transaction signing API where developers needed more flexible ways to add signers to transactions, particularly when working with key hashes directly. This showcased our responsive approach to developer needs and API enhancement.

=== Challenge
- Original API only accepted Address or RewardAddress types
- Developers sometimes had direct access to key hashes
- Needed to maintain backward compatibility
- Required consideration of different signing scenarios

=== Technical Resolution
1. Implemented two distinct methods for maximum flexibility:
   - `addSigner`: Handles Address and RewardAddress inputs
   - `addSignerKey`: Accepts PaymentKeyHash and StakeKeyHash inputs
2. Maintained backward compatibility
3. Enhanced type safety through explicit method separation
4. Provided comprehensive documentation for both approaches

=== Impact for Developers
- More flexible transaction signing options
- Clearer API semantics
- Better support for various implementation scenarios
- Simplified migration from legacy Lucid

== Related Links
- Issue: #link("https://github.com/Anastasia-Labs/lucid-evolution/issues/265")[Enhanced Signer Flexibility #265]
- Implementation PR: #link("https://github.com/Anastasia-Labs/lucid-evolution/pull/272")[Add signer by reward address #272]
- Related Issue: #link("https://github.com/Anastasia-Labs/lucid-evolution/issues/171")[Transaction submission #171]

#pagebreak()
#v(35pt)
= Example 8: Transaction Composition Enhancement

=== Context
The community, particularly Liqwid Labs and other DeFi projects, identified issues with the transaction composition functionality, a critical feature used in 90% of their transaction workflow code. This highlighted the importance of maintaining key features while improving implementation.

=== Challenge
- Transaction composition not functioning as expected
- Need to maintain composability for DeFi integrations
- Balance between clean code and practical functionality
- Required support for complex transaction scenarios

=== Technical Resolution
1. Reimplemented transaction composition with immutability focus
2. Enhanced state management for TxBuilderConfig components:
   - Proper merging of UTxO sets
   - Script deduplication
   - Fee calculation improvements
3. Maintained backward compatibility
4. Added comprehensive testing for composition scenarios

=== Impact for Developers
- Reliable transaction composition for DeFi integrations
- Cleaner, more predictable transaction building
- Better support for complex smart contract interactions
- Improved composability with external SDKs

== Related Links
- Issue: #link("https://github.com/Anastasia-Labs/lucid-evolution/issues/277")[Transaction Composition Fix #277]
- Fix PR: #link("https://github.com/Anastasia-Labs/lucid-evolution/pull/397")[Implement compose functionality #397]
- Implementation: #link("https://github.com/Anastasia-Labs/lucid-evolution/blob/main/packages/lucid/src/tx-builder/TxBuilder.ts")[TxBuilder.ts]

#pagebreak()
#v(35pt)
= Example 9: Seed Phrase Generation and Wallet Creation

=== Context
During community migration from legacy Lucid to Lucid Evolution, a critical issue was identified in the wallet creation process using seed phrases.

=== Challenge
- Seed phrase generation failing with crypto hash finalization error
- Inconsistency between legacy and Evolution implementations
- Critical functionality affecting wallet creation workflows

=== Technical Resolution
1. Identified root cause in SHA256 hash implementation:
   - Legacy Lucid: Using Deno's standard hash library
   - Evolution: Using Node's crypto module
2. Implemented proper hash instance management
3. Added hash state reset functionality
4. Provided comprehensive testing for seed generation scenarios

=== Impact for Developers
- Reliable seed phrase generation
- Consistent wallet creation process
- Smooth migration path from legacy Lucid
- Improved cryptographic operation handling

== Related Links
- Issue: #link("https://github.com/Anastasia-Labs/lucid-evolution/issues/55")[Seed Generation Error #55]
- Fix PR: #link("https://github.com/Anastasia-Labs/lucid-evolution/pull/63")[Fix generateSeedPhrase #63]
- Related Issue: #link("https://github.com/Anastasia-Labs/lucid-evolution/issues/56")[Fix generateSeedPhrase error #56]

#pagebreak()
#v(35pt)
= Example 10: Stake Withdrawal Encoding Compatibility

=== Context
A change in stake withdrawal encoding was identified that affected interactions with existing Plutus V2 scripts.

=== Challenge
- Script purpose encoding changed between versions
- Affected existing Plutus V2 script interactions
- Required maintaining backward compatibility
- Needed coordination with Aiken compiler updates

=== Technical Resolution
1. Identified encoding change impact:
   - Pre v0.3.20: Double-wrapped encoding (121[122[...]])
   - Post v0.3.22: Single-wrapped encoding (122[...])
2. Investigated root cause in UPLC dependencies
3. Coordinated with Aiken team on wrapper changes
4. Released fix through UPLC version update

=== Impact for Developers
- Restored compatibility with existing scripts
- Maintained consistent withdrawal behavior
- Simplified script purpose encoding
- Improved integration with Aiken ecosystem

== Related Links
- Issue: #link("https://github.com/Anastasia-Labs/lucid-evolution/issues/311")[Stake Withdrawal Encoding #311]
- Fix PR: #link("https://github.com/Anastasia-Labs/lucid-evolution/pull/337")[Aiken UPLC Update #337]
- Related Change: #link("https://github.com/aiken-lang/aiken/pull/997")[Aiken Wrapper Update]