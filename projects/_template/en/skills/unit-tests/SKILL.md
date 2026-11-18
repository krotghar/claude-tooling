---
name: unit-tests
description: Standards for writing and editing unit tests in the project — naming, Prepare/Do/Check structure, what and how to assert, stubs without blind checks, determinism. Use when writing or editing any test.
---

# Unit test rules

When writing or editing unit tests, strictly follow these standards adopted in the project.

The primary source is the project's team wiki, the section on unit tests (if there is one).
If this file disagrees with the wiki, the wiki wins.

## 1. Stack and setup

- The test framework, mocking/stubbing libraries and shared base classes/setup helpers
  are **filled in per project** (this section is completed for the stack).
- Until it's filled in, use what the neighbouring tests in the module already use, and
  don't bring in a new test library without agreement.
- Don't change the visibility of production code for a test (don't open up private
  members, don't add "test-only" methods).
- **No helper factory methods and no extra classes for tests**, unless the project has
  agreed otherwise: the input variants you need (empty / null / populated) are named
  values at the test class/file level.

## 2. Test structure and naming

- The test name describes the condition and the expected result: `WHEN [action] EXPECT [result]`.
  The exact notation (given the language's naming restrictions) is filled in per
  project; name new tests like the neighbouring ones.
- Don't use the word `FAILED` or numbers ("test1", "case2") in the name.
- The test is split by comments into three blocks:

  ```
  // Prepare
  ...
  // Do
  ...
  // Check
  ...
  ```

## 3. Assertion rules

- One test — one logical assert.
- **Interaction verification** (that a dependency was called the right number of times
  and there were no extra calls) is done in the same test, doesn't count as a second
  assert, and isn't moved to a separate test.
- Comparing whole objects: when mapping models, compare the entire expected model in a
  single comparison, not field by field.
- Always use variables named `expected` and `actual` in assertions.
- Use real objects, not mocks, for simple data structures.
- Strict type matching: if a method returns a specific collection or value type, use the
  same type in the expected model.
- The test must fail without the change under test: if you delete or break the code under
  test and the test stays green, the assertion is worthless.

## 4. Async, time and stubs

- Test async code and data streams with the test framework's tools (virtual time, test
  scheduler), not real delays and `sleep`.
- Don't tune timeouts and virtual-time steps "with a margin" to make the test green.
- The test is deterministic: no dependence on the current time, random numbers, the
  network or the execution order of other tests — all of these are substituted.
- Verify calls to nested dependencies only one level down.
- A stub must not make the check blind: a stub of a wrapper that returns its own argument
  turns the wrapper into identity, and the test goes green even if the wrapper is removed
  entirely. A stub returns a **distinguishable** value.

## 5. Ignoring and running tests

- A disabled test — via the framework's standard mechanism, with a mandatory reason or
  task number (`PROJ-123`).
- The run command is in the Commands section of the project's `CLAUDE.md`.
