{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}

module SubModel where

import Miso
import Miso.String

{- act not needed in viewModel -}
class SubModel model where
  type PublicActionsType model :: * -> *
  type ActionType model
  viewModel :: PublicActionsType model action -> model -> View action
  updateModel ::
       PublicActionsType model action
    -> ActionType model
    -> model
    -> Effect action model
