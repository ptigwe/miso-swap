{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ExistentialQuantification #-}

module Component where

import Miso
import Miso.String

-- Actions interface
-- These actions are interesting for the parent
data PublicActions action = PublicActions
  { toParent :: ActionIdx -> action -- used to channel events to the component
  , click :: action -- Events that the parent should handle
  }

-- An integer representation of an action for a component
type ActionIdx = Int

-- All `Component_`s should implement two functions
-- `viewModel` which renders the component
-- `updateModel` which updates the Model
class Component_ model where
  viewModel :: model -> PublicActions action -> View action
  updateModel ::
       model -> PublicActions action -> ActionIdx -> Effect action model

-- All `Component_`s should also be instances of `Eq`
-- A `Component` houses a single `Component_`
-- also a `Bool` for equality checks
data Component = forall m. (Component_ m, Eq m) => Component m Bool

-- Allows for easily updating and rendering the `Component`
instance Component_ Component where
  viewModel (Component m _) = viewModel m
  updateModel (Component m b) pa aIdx = do
    newModel <- updateModel m pa aIdx
    let x = m == newModel
    noEff $ Component newModel $ x == b

instance Eq Component where
  Component _ b1 == Component _ b2 = b1 == b2
