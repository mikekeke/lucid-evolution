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

= Introduction
#v(35pt)
Our team has been hard at work, crafting a toolkit that makes Cardano's new governance capabilities accessible and intuitive for developers and users. This report dives into the nuts and bolts, showcasing how we've translated Cardano's complex governance model into a developer-friendly library and how our extensive testing modules cover all endpoints and succesfully run both on Preview and Preprod networks with every update we push




#pagebreak()
#v(35pt)
= SanchoNet Feature Implementation and Testing
#v(15pt)
Document with test cases covering various aspects of SanchoNet features, such as functionality, performance, and integration:

#v(15pt)
== Test Cases Overview
#v(15pt)
Our testing suite for SanchoNet features is extensive and includes direct on-chain execution of tests. This approach shows that our transaction builder library is reliable in real-world scenarios. We can group these tests under

DRep Operations:
- Register DRep
- Deregister DRep
- Update DRep

Voting Delegation:
- Delegate vote to DRep (Always Abstain)
- Delegate vote to DRep (Always No Confidence)
- Delegate vote to Pool and DRep

Combined Registration and Delegation:

- Register and delegate to Pool
- Register and delegate to DRep
- Register and delegate to Pool and DRep

Script-based DRep Operations:
- Register Script DRep
- Deregister Script DRep

#pagebreak()
#v(35pt)
== Individual Test Cases Displayed
#v(15pt)
These test cases can be found in our `onchain-preview.test.ts`, `onchain-preprod.test.ts` and specifically the `governance.ts`  files in our library:

=== DRep Operations
==== Register DRep
```ts
export const registerDRep = Effect.gen(function* ($) {
  const { user } = yield* User;
  const rewardAddress = yield* pipe(
    Effect.promise(() => user.wallet().rewardAddress()),
    Effect.andThen(Effect.fromNullable),
  );
  const signBuilder = yield* user
    .newTx()
    .register.DRep(rewardAddress)
    .setMinFee(200_000n)
    .completeProgram();
  return signBuilder;
}).pipe(
  Effect.flatMap(handleSignSubmit),
  Effect.catchTag("TxSubmitError", (error) => Effect.fail(error)),
  withLogRetry,
  Effect.orDie,
);
```

==== Deregister DRep

```ts
export const deregisterDRep = Effect.gen(function* ($) {
  const { user } = yield* User;
  const rewardAddress = yield* pipe(
    Effect.promise(() => user.wallet().rewardAddress()),
    Effect.andThen(Effect.fromNullable),
  );
  const signBuilder = yield* user
    .newTx()
    .deregister.DRep(rewardAddress)
    .completeProgram();
  return signBuilder;
}).pipe(Effect.flatMap(handleSignSubmit), withLogRetry, Effect.orDie);
``` 

==== Update DRep

```ts
export const updateDRep = Effect.gen(function* ($) {
  const { user } = yield* User;
  const rewardAddress = yield* pipe(
    Effect.promise(() => user.wallet().rewardAddress()),
    Effect.andThen(Effect.fromNullable),
  );
  const signBuilder = yield* user
    .newTx()
    .updateDRep(rewardAddress)
    .completeProgram();
  return signBuilder;
}).pipe(Effect.flatMap(handleSignSubmit), withLogRetry, Effect.orDie);
``` 

=== Voting Delegation
==== Delegate vote to DRep (Always Abstain)

```ts
export const voteDelegDRepAlwaysAbstain = Effect.gen(function* ($) {
  const { user } = yield* User;
  const rewardAddress = yield* pipe(
    Effect.promise(() => user.wallet().rewardAddress()),
    Effect.andThen(Effect.fromNullable),
  );
  const signBuilder = yield* user
    .newTx()
    .delegate.VoteToDRep(rewardAddress, {
      __typename: "AlwaysAbstain",
    })
    .completeProgram();
  return signBuilder;
}).pipe(Effect.flatMap(handleSignSubmit), withLogRetry, Effect.orDie);
```

#pagebreak()
#v(35pt)
==== Delegate vote to DRep (Always No Confidence)

```ts
export const voteDelegDRepAlwaysNoConfidence = Effect.gen(function* ($) {
  const { user } = yield* User;
  const rewardAddress = yield* pipe(
    Effect.promise(() => user.wallet().rewardAddress()),
    Effect.andThen(Effect.fromNullable),
  );
  const signBuilder = yield* user
    .newTx()
    .delegate.VoteToDRep(rewardAddress, {
      __typename: "AlwaysNoConfidence",
    })
    .completeProgram();
  return signBuilder;
}).pipe(Effect.flatMap(handleSignSubmit), withLogRetry, Effect.orDie);
```

==== Delegate vote to Pool and DRep

```ts
export const voteDelegPoolAndDRepAlwaysAbstain = Effect.gen(function* ($) {
  const { user } = yield* User;
  const networkConfig = yield* NetworkConfig;
  const rewardAddress = yield* pipe(
    Effect.promise(() => user.wallet().rewardAddress()),
    Effect.andThen(Effect.fromNullable),
  );
  const poolId =
    networkConfig.NETWORK == "Preprod"
      ? "pool1nmfr5j5rnqndprtazre802glpc3h865sy50mxdny65kfgf3e5eh"
      : "pool1ynfnjspgckgxjf2zeye8s33jz3e3ndk9pcwp0qzaupzvvd8ukwt";

  const signBuilder = yield* user
    .newTx()
    .delegate.VoteToPoolAndDRep(rewardAddress, poolId, {
      __typename: "AlwaysAbstain",
    })
    .completeProgram();
  return signBuilder;
}).pipe(Effect.flatMap(handleSignSubmit), withLogRetry, Effect.orDie);
```

=== Combined Registration and Delegation
==== Register and delegate to Pool
```
export const registerAndDelegateToPool = Effect.gen(function* ($) {
  const { user } = yield* User;
  const networkConfig = yield* NetworkConfig;
  const poolId =
    networkConfig.NETWORK == "Preprod"
      ? "pool1nmfr5j5rnqndprtazre802glpc3h865sy50mxdny65kfgf3e5eh"
      : "pool1ynfnjspgckgxjf2zeye8s33jz3e3ndk9pcwp0qzaupzvvd8ukwt";

  const rewardAddress = yield* pipe(
    Effect.promise(() => user.wallet().rewardAddress()),
    Effect.andThen(Effect.fromNullable),
  );
  const signBuilder = yield* user
    .newTx()
    .registerAndDelegate.ToPool(rewardAddress, poolId)
    .completeProgram();
  return signBuilder;
}).pipe(Effect.flatMap(handleSignSubmit), withLogRetry, Effect.orDie);
```

==== Register and delegate to DRep

```ts
export const registerAndDelegateToDRep = Effect.gen(function* ($) {
  const { user } = yield* User;
  const rewardAddress = yield* pipe(
    Effect.promise(() => user.wallet().rewardAddress()),
    Effect.andThen(Effect.fromNullable),
  );
  const signBuilder = yield* user
    .newTx()
    .registerAndDelegate.ToDRep(rewardAddress, {
      __typename: "AlwaysAbstain",
    })
    .completeProgram();
  return signBuilder;
}).pipe(Effect.flatMap(handleSignSubmit), withLogRetry, Effect.orDie);
```

==== Register and delegate to Pool and DRep

```ts
export const registerAndDelegateToPoolAndDRep = Effect.gen(function* ($) {
  const { user } = yield* User;
  const rewardAddress = yield* pipe(
    Effect.promise(() => user.wallet().rewardAddress()),
    Effect.andThen(Effect.fromNullable),
  );
  const networkConfig = yield* NetworkConfig;
  const poolId =
    networkConfig.NETWORK == "Preprod"
      ? "pool1nmfr5j5rnqndprtazre802glpc3h865sy50mxdny65kfgf3e5eh"
      : "pool1ynfnjspgckgxjf2zeye8s33jz3e3ndk9pcwp0qzaupzvvd8ukwt";
  const signBuilder = yield* user
    .newTx()
    .registerAndDelegate.ToPoolAndDRep(rewardAddress, poolId, {
      __typename: "AlwaysAbstain",
    })
    .completeProgram();
  return signBuilder;
}).pipe(Effect.flatMap(handleSignSubmit), withLogRetry, Effect.orDie);
```
#pagebreak()
#v(35pt)
=== Script-based DRep Operations
==== Register Script DRep

```ts
export const registerScriptDRep = Effect.gen(function* ($) {
  const { user } = yield* User;
  const { rewardAddress, script } = yield* AlwaysYesDrepContract;
  const signBuilder = yield* user
    .newTx()
    .register.DRep(rewardAddress, undefined, Data.void())
    .attach.Script(script)
    .completeProgram();
  return signBuilder;
}).pipe(
  Effect.flatMap(handleSignSubmit),
  Effect.catchTag("TxSubmitError", (error) => Effect.fail(error)),
  withLogRetry,
  Effect.orDie,
);
```

==== Deregister Script DRep

```ts
export const deregisterScriptDRep = Effect.gen(function* ($) {
  const { user } = yield* User;
  const { rewardAddress, script } = yield* AlwaysYesDrepContract;
  const signBuilder = yield* user
    .newTx()
    .deregister.DRep(rewardAddress, Data.void())
    .attach.Script(script)
    .completeProgram();
  return signBuilder;
}).pipe(
  Effect.flatMap(handleSignSubmit),
  Effect.catchTag("TxSubmitError", (error) => Effect.fail(error)),
  withLogRetry,
  Effect.orDie,
);
```
#pagebreak()
#v(35pt)
=== Committee Certificates Implementation (PR #313)
#v(15pt)
Following the initial governance features, Lucid Evolution expanded its capabilities to include committee-related operations:

1. Committee Hot Key Authorization:
   A new method `authCommitteeHot` was added to authorize a hot key for a committee member


```typescript
packages/lucid/src/tx-builder/TxBuilder.ts
startLine: 479
endLine: 490
```

2. Committee Member Resignation:
   The `resignCommitteeHot` method was introduced to allow committee members to resign their position

```typescript
packages/lucid/src/tx-builder/TxBuilder.ts
startLine: 491
endLine: 499
```

and governance specific `propose` validator operations together with the updated script attachments

#pagebreak()
#v(35pt)
== Effect Library Integration
#v(15pt)
We have rewritten Lucid from scratch, incorporating the Effect library to provide developers with improved error managemen.

Through this we provide better error handling via Effect library which allows developers for more precise error messages.

Our test suite, including the SanchoNet feature tests, is regularly executed as part of our continuous integration process. 

= Test Execution Results

Our testing methodology involves executing over 100 CI tests directly on the Cardano preprod and preview networks. This approach allows for real-world validation by running tests on actual Cardano networks, as we ensure that our library functions correctly in production-like environments.

As part of our CI pipeline, these tests are run regularly, making sure of ongoing compatibility and reliability with each new version released of `lucid-evolution`.

== Proof Video
Example test execution of all our tests in our testing suite passing (from `onchain-preprod.test.ts`):


#align(center)[== Proof video

#link("https://x.com/solidsnakedev/status/1846633770964996590")[VIDEO]
]

= Testing of Conway Era functions
#v(15pt)

To ensure consistency across different Cardano environments, we run our test suite on both the Preview and Preprod networks:

- `packages/lucid/test/onchain-preview.test.ts`

- `packages/lucid/test/onchain-preprod.test.ts`


#align(center)[== GIF Testrun

#link("https://github.com/Anastasia-Labs/lucid-evolution/blob/main/assets/images/governance.gif")[Succesful Test Result]
\
\

This GIF, *a onchain test* running in terminal,
showcases \ that our test packages are working as intended by running succesful test cases

]

#pagebreak()
#v(35pt)
= Bug Identification
#v(15pt)
== Ongoing Development

The governance features in Lucid Evolution are in a state of continuous development and refinement. As the Conway era and its associated governance mechanisms are still evolving, our library adapts to keep pace with the latest community discussions and protocol changes.

Our codebase is designed to be easily adaptable to changes in the governance protocol. We maintain an extensive suite of on-chain tests to ensure reliability across different scenarios. We closely follow constitutional workshops and governing body elections to align our features with the community's needs.


#pagebreak()
#v(35pt)
= Optimizations
#v(15pt)
We made further enhancements to our governance-related endpoints and made sure they are all live and functioning with each of our releases on the Cardano Network for developers to utilize. 

We've implemented a range of DRep (Delegate Representative) operations, including registration, deregistration, and updates. Added support for various voting delegation scenarios, including "Always Abstain" and "Always No Confidence" options.
Easy convenience functions to streamline functions that allow users to register and delegate in a single transaction and the extended TxBuilder including governance-specific methods, to enabing creation of highly efficient governance era transactions.

After our implementations we took a look back at how our Transaction builder (`TxBuilder`) was functioning and made iterative design choices to increase performance in all our endpoints.

== How?

By strategically making IO-bound computations optional by allowing preset protocol parameters during Lucid initialization and preset wallet UTXOs during transaction building.
As a result of this design choice we can increase the quality of UX for Cardano Governance era - where all of us are most focused at the moment. This will be followed by more deep dives into how we can make the library smoother and easier to use for all developers on Cardano.

To not crowd this report with big code blocks, we present the direct change visible between these two states of the evolution library governance endpoints:

- #link("https://github.com/Anastasia-Labs/lucid-evolution/blob/main/packages/lucid/test/specs/governance-unoptimized.ts")[Previous version (Unoptimized)]

- #link("https://github.com/Anastasia-Labs/lucid-evolution/blob/main/packages/lucid/test/specs/governance-optimized.ts")[Newest version (Optimized)]

#pagebreak()



#v(35pt)
= Performance Benchmark
#v(15pt)

Build times represented in miliseconds

== Previous Governance Endpoint

- registerDRep: 2234ms 
- updateDRep: 2161ms 
- deregisterDRep: 2261ms
- registerScriptDRep: 2198ms
- deregisterScriptDRep: 2195ms

== Optimized Governance Endpoint

- registerDRep: Slashed from 2234ms to a mere 11ms
- updateDRep: Improved from 2161ms to just 9ms
- deregisterDRep: Enhanced from 2261ms to 9ms
- registerScriptDRep: Reduced from 2198ms to 19ms
- deregisterScriptDRep: Down from 2195ms to 19ms

A direct comparison between the legacy lucid library and the evolution library can not be provided as governance features are not supported on Lucid 0.10.7. The optimized results are a comparison between previos implementation and its current state in Lucid Evolution library.

#v(35pt)

