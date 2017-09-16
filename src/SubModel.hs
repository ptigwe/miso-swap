{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ExistentialQuantification #-}

module SubModel where

import Miso
import Miso.String

data PublicActions action = PublicActions
  { toParent :: ActionIdx -> action
  , click :: action
  }

type ActionIdx = Int

{- act not needed in viewModel -}
class SubModel_ model where
  viewModel :: model -> PublicActions action -> View action
  updateModel ::
       model -> PublicActions action -> ActionIdx -> Effect action model

data SubModel =
  forall m. (SubModel_ m, Eq m) =>
            SubModel m

instance SubModel_ SubModel where
  viewModel (SubModel m) = viewModel m
  updateModel (SubModel m) pa aIdx = do
    newModel <- updateModel m pa aIdx
    noEff $ SubModel newModel

instance Eq SubModel where
  SubModel m1 == SubModel m2 = False
