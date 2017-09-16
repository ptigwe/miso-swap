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
import qualified SubModel as S

import Miso
import Miso.String

data Model = Model
  { additive :: S.SubModel
  , currentModel :: String
  } deriving (Eq)

data Action
  = Swap
  | SubModelAction !S.ActionIdx
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
initialModel = Model (S.SubModel A.initialModel) "Additive"

initialModel2 :: Model
initialModel2 = Model (S.SubModel M.initialModel) "Multiplicative"

additivePa :: S.PublicActions Action
additivePa = S.PublicActions {S.toParent = SubModelAction, S.click = NoOp}

updateModel :: Action -> Model -> Effect Action Model
updateModel (SubModelAction act) m@Model {..} = do
  addModel <- S.updateModel additive additivePa act
  noEff m {additive = addModel}
updateModel Swap (Model _ "Additive") = noEff initialModel2
updateModel Swap (Model _ "Multiplicative") = noEff initialModel
updateModel NoOp m = noEff m

display :: Model -> View Action
display m@Model {..} =
  div_
    []
    [ button_ [onClick Swap] [text "Swap"]
    , p_ [] [text . pack $ "Model : ", b_ [] [text . pack $ currentModel]]
    , S.viewModel additive additivePa
    ]
