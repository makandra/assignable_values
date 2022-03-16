All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased

### Breaking changes

-

### Compatible changes

-

## 0.16.6 - 2022-03-16

### Breaking changes

- Remove no longer supported ruby versions (2.3.8, 2.4.2)
- Activate rubygems MFA

### Compatible changes

- test against ActiveRecord 7.0

## 0.16.5 - 2021-01-10

### Compatible changes

- Previously assigned values are no longer duplicated when calling the assignable_values method (fixes #32)

## 0.16.4 - 2020-10-15

### Compatible changes

- No longer crashes value blocks return `nil`.


## 0.16.3 - 2020-10-15

### Compatible changes

- No longer crashes when assigning `nil` to an attribute with assignable values that are provided as a scope.


## 0.16.2 - 2020-10-06

### Compatible changes

- when given a scope, do not load all records to memory during validation


## 0.16.1 - 2019-05-14

### Compatible changes

- add tests for Rails 6
- Humanized assignable value methods now also take the include_old_values option (fixes #25)


## 0.16.0 - 2019-02-20

### Breaking changes

- fix arity bug


## 0.15.1 - 2018-11-05

### Compatible changes

- Add `#humanized_values` for the `multiple: true` case.


## 0.15.0 - 2018-10-26

### Breaking changes

- `#humanized_values` is deprecated, in favour of `#humanized_assignablevalues`

### Compatible changes

- `#humanized_value(value)` and `#humanized_assignable_values` now also works for the `multiple: true` case


## 0.14.0 - 2018-09-17

### Compatible changes

- Add support for Array columns using `multiple: true`.


## 0.13.2 - 2018-01-23

### Compatible changes

- Get rid of deprecation warnings on Rails 5.1+.

Thanks to irmela.


## 0.13.1 - 2017-10-24

### Compatible changes

- Add Rails 5.1 compatibility.

Thanks to GuidoSchweizer.


## 0.13.0 - 2017-09-08

### Breaking changes

- No longer support providing humanized values as a hash in favour of always using I18n.

### Compatible changes

- Fix a bug with a `has_many :through` when return a nil object.

Thanks to foobear.


## Older releases

Please check commits.
