# Changelog

## [0.1.0] - 2024-02-2

- Initial release extracted from CloudAlly gem

## [0.1.1] - 2024-02-5

- default endpoint to nil and raise error in connection when not available

## [0.1.2] - 2024-02-5

- default endpoint to nil and raise error in connection when not available

## [0.1.3] - 2024-02-5

- fix entity should return empty array insted of nil

## [0.2.0] - 2024-02-8

- implement json pagination

## [0.2.0] - 2024-02-13

- implement option to manipulate request

## [0.4.0] - 2024-02-13

- testing/code quality
  authentication tests (mocked)
  test string/{}/[] entities returned with mock
  request tests with mock including delete/put/post
- Entity fix issues returning json arrays
  Request option to return raw response

## [0.4.1] - 2024-02-28

- fix issue with post body only supported as json

## [0.4.2] - 2024-03-03

- fix issue with escaping query parameters included in path

## [0.4.3] - 2024-03-07

- fix issue json generation for updated attributes

## [0.4.4] - 2024-03-12

- fix typo and implement clone for entities

## [0.4.5] - 2024-03-12

- refactorings code readability

## [0.4.6] - 2024-06-17

- fix issue with loading Entity from yaml

## [0.4.7] - 2025-03-18

- fix obsolete escape

## [0.4.8] - 2025-03-20

- scramble passwords in www encoded content

## [0.4.9] - 2025-03-20

- freeze causes issue so connection options can't be merged!

## [0.5.0] - 2025-10-20

- generic use of token type

## [0.5.1] - 2025-11-10

- do not assign token type when empty
