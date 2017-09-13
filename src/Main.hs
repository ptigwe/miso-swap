{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE MultiWayIf #-}
{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE ExistentialQuantification #-}

module Main where

import qualified Additive as A
import Data.Function
import qualified Data.Map as M
import Data.Monoid
import qualified SubModel

import Miso
import Miso.String

data Model = Model
  { additive :: A.Model
  , currentModel :: String
  } deriving (Show, Eq)

data Action
  = Swap
  | AdditiveAction !A.Action
  | NoOp

main :: IO ()
main = do
  startApp App {model = initialModel, initialAction = Swap, ..}
  where
    update = updateModel
    view = display
    events = defaultEvents
    subs = []

initialModel :: Model
initialModel = Model A.initialModel "Additive"

additivePa :: A.PublicActions Action
additivePa = A.PublicActions {A.toParent = AdditiveAction, A.click = NoOp}

updateModel :: Action -> Model -> Effect Action Model
updateModel (AdditiveAction act) m = do
  addModel <- SubModel.updateModel additivePa act $ additive m
  noEff m {additive = addModel}
updateModel Swap m = noEff m
updateModel NoOp m = noEff m

display :: Model -> View Action
display m@Model {..} =
  div_
    []
    [ button_ [onClick Swap] [text "Swap"]
    , p_ [] [text . pack $ "Model : ", b_ [] [text . pack $ currentModel]]
    , SubModel.viewModel additivePa A.NoOp additive
    ]
