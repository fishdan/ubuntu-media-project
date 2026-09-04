# Feature Specification: Branch and Merge Governance

**Feature Branch**: `0.014-branch-merge-governance`  
**Created**: 2026-09-04  
**Status**: Complete

**Input**: Require future project work to be completed on branches and merged into `main`.

## Requirements

- **FR-001**: Feature, fix, refactor, configuration, and documentation work MUST be performed on a non-`main` branch.
- **FR-002**: Completed branch work MUST be validated and merged into `main`.
- **FR-003**: A direct commit to `main` requires explicit human authority for the specific change or an emergency recovery need, and the exception MUST be recorded.

## Success Criteria

- **SC-001**: The project constitution states the branch-and-merge policy and its narrow exception.

## Scope

This documentation-only feature establishes repository governance; it does not alter appliance configuration.
