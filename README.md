# Expressive

A tool for:

- Finding very code factoring problems, aiming for highly decomposable functional code.
- First feature will be checker for function definitions with large bodies.
- Automating some common development tasks, such as creating a new module with an appropriate file name.

Usage:

- `mix new.module Some.Module.Name` will create a file `lib/some/module/name.ex`
- `mix check --lfb` will search for functions with bodies consisting of more than 1 single expression