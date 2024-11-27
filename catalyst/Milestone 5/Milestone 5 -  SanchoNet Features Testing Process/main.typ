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
#set text(15pt); Testing and Optimization for SanchoNet Features\ *Project Close-out Report* ]

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

= Introduction
#v(35pt)
Lucid evolution from its inception had the goal to become the go-to off chain library, creating a streamlined development process for offchain on Cardano. We aimed to make this a reality by creating Lucid Evolution library and work on it 24/7. Everyday we help developers fix their problems, answer questions and also learn ourvelselves from them.

We had an amazing experience watching the growth of the library, hearing that our rejuvenation of the legacy Lucid library major Cardano dApps and entities rely on the enhanced Lucid Eolution for their operations.

We have crossed the 1000+ commits mark some time ago now, and watch the continous increase of dApps powered by the Evolution library.


= Evidence Definition 

Provided documentation and reports detailing the testing process conducted on SanchoNet features integrated with Lucid is available at https://github.com/Anastasia-Labs/lucid-evolution


#pagebreak()
#v(35pt)
= SanchoNet Feature Implementation and Testing

#v(15pt)
== Test Cases Overview
#v(15pt)

For this overview we will display what our testing suite covers, and how we ourselves  are always on the lookout for upgrades / bugs / undiscovered minor issues and these is possible to track 

Our testing suite for SanchoNet features is extensive and includes direct on-chain execution of tests. This approach shows that our transaction builder library is reliable in real-world scenarios. We can group these tests under:

#v(15pt)

#box(height: 160pt,
 columns(2,gutter: 20pt)[

   *DRep Operations*
- Register DRep
- Deregister DRep
- Update DRep

*Voting Delegation*
- Delegate vote to DRep (Always Abstain)
- Delegate vote to DRep (Always No Confidence)
- Delegate vote to Pool and DRep

*Combined Registration and Delegation*

- Register and delegate to Pool
- Register and delegate to DRep
- Register and delegate to Pool and DRep

*Script-based DRep Operations*
- Register Script DRep
- Deregister Script DRep

])

#v(15pt)
== Effect Library Integration
#v(15pt)
We have rewritten Lucid from scratch, incorporating the Effect library to provide developers with improved error managemen.

Through this we see better error handling via Effect library which allows developers for more precise operations as increased error messages handling make troubleshooting easier for everyone.

Our test suite, including the SanchoNet feature tests, is regularly executed as part of our continuous integration process. 

#pagebreak()
#v(35pt)
== Individual Test Cases Displayed
#v(15pt)
These test cases can be found in our `onchain-preview.test.ts`, `onchain-preprod.test.ts` and specifically the `governance.ts`  files in our library. 

Each test implements proper error handling through `Effect.orDie` and includes retry logic via `withLogRetry` to ensure reliable test execution. Our suite is designed to work across both `Preview` and `Preprod` networks, with appropriate network-specific configurations.:

=== DRep Operations
==== Register DRep
Tests the creation of new DReps by registering a reward address as a DRep with optimized fee calculations
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
#pagebreak()
#v(25pt)
==== Deregister DRep
Ensures proper removal of DRep credentials from the system
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
Validates the ability to modify existing DRep metadata and credentials
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
#pagebreak()
#v(25pt)
=== Voting Delegation
==== Delegate vote to DRep (Always Abstain)
Tests delegation to a DRep with an "always abstain" voting pattern
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

==== Delegate vote to DRep (Always No Confidence)
Validates delegation with "always no confidence" voting behavior
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
#pagebreak()
#v(35pt)
==== Delegate vote to Pool and DRep
Tests the complex scenario of simultaneous stake pool and DRep delegation
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
#pagebreak()
#v(35pt)
=== Combined Registration and Delegation
==== Register and delegate to Pool
Tests simultaneous stake registration and pool delegation
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
#pagebreak()
==== Register and delegate to DRep
combined DRep registration and voting delegation
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
Tests the most complex scenario of registering and delegating to both a pool and DRep in a single transaction
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
Tests the registration of script-based DReps, including proper script attachment and validation
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
Ensures proper cleanup of script-based DRep credentials
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


