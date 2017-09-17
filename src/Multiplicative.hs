{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeFamilies #-}

module Multiplicative where

import Component
import Miso
import Miso.String

-- Model for the Additive Component
data Model = Model
  { counter :: Int
  , clickCount :: Int
  } deriving (Eq, Show)

initialModel :: Model
initialModel = Model 1 0

-- Actions for this component
data Action
  = Multiply
  | Divide
  | NoOp
  deriving (Show, Eq)

-- Map integers to Actions
idxToAction :: ActionIdx -> Action
idxToAction 0 = Multiply
idxToAction 1 = Divide
idxToAction _ = NoOp

-- Map Actions to integers
actionIdx :: Action -> ActionIdx
actionIdx Multiply = 0
actionIdx Divide = 1
actionIdx NoOp = 2

instance Component_ Model where
  updateModel m@Model {..} pa aIdx =
    case action of
      Multiply ->
        m {counter = counter * 2} <# do
          putStrLn $ "Multiply" ++ show counter
          pure $ click pa
      Divide ->
        m {counter = max 1 $ counter `div` 2} <# do
          putStrLn $ "Divide" ++ show counter
          pure $ click pa
      NoOp -> noEff m
    where
      action = idxToAction aIdx
  viewModel m pa =
    div_
      []
      [ button_ [onClick $ toParent pa $ actionIdx Multiply] [text "*"]
      , text . ms . show . counter $ m
      , button_ [onClick $ toParent pa $ actionIdx Divide] [text "/"]
      ]
