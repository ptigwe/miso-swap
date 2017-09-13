{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FunctionalDependencies #-}

module SubModel where

import Miso
import Miso.String

{- act not needed in viewModel -}
class SubModel pa act model | model -> act where
  viewModel :: pa action -> model -> View action
  updateModel :: pa action -> act -> model -> Effect action model
