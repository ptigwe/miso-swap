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
                     Bool

instance SubModel_ SubModel where
  viewModel (SubModel m _) = viewModel m
  updateModel (SubModel m b) pa aIdx = do
    newModel <- updateModel m pa aIdx
    let x = m == newModel
    noEff $ SubModel newModel $ x == b

instance Eq SubModel where
  SubModel _ b1 == SubModel _ b2 = b1 == b2
