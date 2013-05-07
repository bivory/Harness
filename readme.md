# Harness

Run unit tests and keep a history of the results!

## Installation

Download from https://github.com/bivory/harness and mirror the directory structure listed in the "Directory" section.

## Usage

    % ./harness.rb
    % ./harness.rb run all
    % ./harness.rb classify success
    % ./harness.rb results -v

## Commands

run: Creates a new results/DATETIME directory and runs all the tests in tests/ and saves the results in results/DATETIME.

results: Compares all the actual results in results/DATETIME to the expected results. If the results match, the test is marked successful. If the results don't match, the test is marked unsuccessful. If the test doesn't have an expected result the test is marked unclassified. If the use classifies the test as failed, the test is marked unsuccessful.

classify: Allows the user to classify the results of running tests as successful or failed. If the user marks a test as successful, the result is copied to the expected directory for comparisons against future test results. If the user marks a test as failed, the result to given the extension 'failedresult' to differentiate it from an unclassified test.

help:  Shows the help prompt.

## Command Options

```
run: Run the unclassified tests.
    all: Run all the tests.
    failed: Run just the failed tests.
    unclassified: Run just the unclassified tests.

results: Print the test results.
    -v: Verbose file printing.

classify: Classify a result.
    ex: classify success <file>
    ex: classify success
       success: Mark test successful.
       failed: Mark test failed.
```

## Directory Structure
- tests/
    - All the tests to run.
- results/
    - expected/
        - The expected (classified successful) results. These results are compared to future tests runs and are considered the correct output to the tests.
    - run_DATETIME/
        - The output from a test run at DATETIME. Files with the extension 'result' are the output from a test. Files with the extension 'failedresult' are the output from a test that didn't have an expected result and was classified by the user as a failed test.


## License

Copyright © 2013 Bryan Ivory

Distributed under the Eclipse Public License.
