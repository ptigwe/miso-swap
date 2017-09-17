{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeFamilies #-}

module Additive where

import Component
import Miso
import Miso.String

-- Model for the Additive Component
data Model = Model
  { counter :: Int
  , clickCount :: Int
  } deriving (Eq, Show)

initialModel :: Model
initialModel = Model 0 0

-- Actions for this component
data Action
  = Subtract
  | Add
  | NoOp
  deriving (Show, Eq)

-- Map integers to Actions
idxToAction :: ActionIdx -> Action
idxToAction 0 = Subtract
idxToAction 1 = Add
idxToAction _ = NoOp

-- Map Actions to integers
actionIdx :: Action -> ActionIdx
actionIdx Subtract = 0
actionIdx Add = 1
actionIdx NoOp = 2

instance Component_ Model where
  updateModel m@Model {..} pa aIdx =
    case action of
      Subtract ->
        m {counter = counter - 1} <# do
          putStrLn $ "Subtract " ++ show counter
          pure $ click pa
      Add ->
        m {counter = counter + 1} <# do
          putStrLn $ "Add" ++ show counter
          pure $ click pa
      NoOp -> noEff m
    where
      action = idxToAction aIdx
  viewModel m pa =
    div_
      []
      [ button_ [onClick $ toParent pa $ actionIdx Add] [text "+"]
      , text . ms . show . counter $ m
      , button_ [onClick $ toParent pa $ actionIdx Subtract] [text "-"]
      ]
