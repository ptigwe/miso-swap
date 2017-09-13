{-# LANGUAGE MultiParamTypeClasses #-}

module SubModel where

import Miso
import Miso.String

{- act not needed in viewModel -}
class SubModel pa act model where
  viewModel :: pa action -> act -> model -> View action
  updateModel :: pa action -> act -> model -> Effect action model
