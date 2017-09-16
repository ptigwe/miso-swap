{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ExistentialQuantification #-}

module Component where

import Miso
import Miso.String

data PublicActions action = PublicActions
  { toParent :: ActionIdx -> action
  , click :: action
  }

type ActionIdx = Int

{- act not needed in viewModel -}
class Component_ model where
  viewModel :: model -> PublicActions action -> View action
  updateModel ::
       model -> PublicActions action -> ActionIdx -> Effect action model

data Component =
  forall m. (Component_ m, Eq m) =>
            Component m
                      Bool

instance Component_ Component where
  viewModel (Component m _) = viewModel m
  updateModel (Component m b) pa aIdx = do
    newModel <- updateModel m pa aIdx
    let x = m == newModel
    noEff $ Component newModel $ x == b

instance Eq Component where
  Component _ b1 == Component _ b2 = b1 == b2
