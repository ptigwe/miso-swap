{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE MultiWayIf #-}
{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE ExistentialQuantification #-}

module Main where

import qualified Additive as A
import Data.Function
import Data.Monoid
import qualified Multiplicative as M
import qualified SubModel

import Miso
import Miso.String

data Model = Model
  { additive :: M.Model
  , currentModel :: String
  } deriving (Show, Eq)

data Action
  = Swap
  | AdditiveAction !A.Action
  | MultiplicativeAction !M.Action
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
initialModel = Model M.initialModel "Additive"

additivePa :: M.PublicActions Action
additivePa = M.PublicActions {M.toParent = MultiplicativeAction, M.click = NoOp}

updateModel :: Action -> Model -> Effect Action Model
updateModel (MultiplicativeAction act) m = do
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
    , SubModel.viewModel additivePa additive
    ]
