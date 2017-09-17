# Swappable Components in Miso

Based on an example by [FPtje](https://github.com/FPtje), which shows how to create reusable
components ([miso-component-example](https://github.com/FPtje/miso-component-example)). This
example aims at extending this idea to allow for swappable components.

## Miniature Example

A miniature example showing how this works can be found in `src/Mini.hs`. This example neither
updates the submodel nor have actions in the view of the submodel.

## Problem

You have tried [miso](http://haskell-miso.org/) and understand how to build apps with it. You have
also tried the [miso-component-example](https://github.com/FPtje/miso-component-example) which
allows you to divide your apps into components. However, there are certain instances where you might
want to have swappable components. For instance, a different menu for regular users and
administrators, or a webapp with customizable widgets. Each component should:

- Be reusable,
- Have its own state (`Model`),
- Communicate certain events back to the parent,
- Keep its `Action`s to itself,
- Be able to embed itself,
- Be able to swap between different components.

## The Pattern

The pattern is divided into three parts:

- `Component.hs` which describes the swappable components,
- `Additive.hs` and `Multiplicative.hs` which are the swappable components,
- `Main.hs` which shows these components embedded in a model.

### Component

The first thing we define is `ActionIdx` which helps us have a generic action type for actions
within the different components. Following this, we have a `PublicActions` which is used to define
which actions are important for the parent to be aware of. Also defined, is a class `Component_`
which all swappable component must be instances of. All components must also be an instance of `Eq`.

The `Component_` class defines two functions:

- `viewModel :: model -> PublicActions action -> View action` : which renders the component
- `updateModel :: model -> PublicActions action -> ActionIdx -> Effect action model`: which updates
the component

Finally, there is a data type `Component`, which acts as a housing for all instances of
`Component_`. It is made up of two types, the first of which is an instance of `Component_` while
the second is a `Bool` which helps with the check for equality.

### Component Model

This works in a very similar way to that of [miso-component-example](https://github.com/FPtje/miso-component-example).
The key difference being the addition of two functions:

- `idxToAction :: ActionIdx -> Action` primarily to be used within the `updateModel` function,
- `actionIdx :: Action -> ActionIdx` primarily to be used in the `viewModel` function.

## Running the example

### Stack

From this directory, run

```
stack build
```

Then open `$(stack path --local-install-root)/bin/app.jsexe/index.html`


### Nix

Not yet tested, however, `nix-build` should work.
