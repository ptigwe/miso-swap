{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RecordWildCards #-}

module Additive where

import Miso
import Miso.String
import SubModel

data Model = Model
  { counter :: Int
  , clickCount :: Int
  } deriving (Eq, Show)

initialModel :: Model
initialModel = Model 0 0

data PublicActions action = PublicActions
  { toParent :: Action -> action
  , click :: action
  }

data Action
  = Subtract
  | Add
  | NoOp
  deriving (Show, Eq)

instance SubModel PublicActions Action Model where
  updateModel pa action m@Model {..} =
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
  viewModel pa m =
    div_
      []
      [ button_ [onClick $ toParent pa Add] [text "+"]
      , text . ms . show . counter $ m
      , button_ [onClick $ toParent pa Subtract] [text "-"]
      ]
