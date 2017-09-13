{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeFamilies #-}

module Multiplicative where

import Miso
import Miso.String
import SubModel

data Model = Model
  { counter :: Int
  , clickCount :: Int
  } deriving (Eq, Show)

initialModel :: Model
initialModel = Model 1 0

data PublicActions action = PublicActions
  { toParent :: Action -> action
  , click :: action
  }

data Action
  = Multiply
  | Divide
  | NoOp
  deriving (Show, Eq)

instance SubModel Model where
  type PublicActionsType Model = PublicActions
  type ActionType Model = Action
  updateModel pa action m@Model {..} =
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
  viewModel pa m =
    div_
      []
      [ button_ [onClick $ toParent pa Multiply] [text "*"]
      , text . ms . show . counter $ m
      , button_ [onClick $ toParent pa Divide] [text "/"]
      ]
