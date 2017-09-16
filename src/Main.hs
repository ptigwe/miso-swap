{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE MultiWayIf #-}
{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE ExistentialQuantification #-}

module Main where

import qualified Additive as A
import qualified Component as C
import Data.Function
import Data.Monoid
import qualified Multiplicative as M

import Miso
import Miso.String

data Model = Model
  { additive :: C.Component
  , currentModel :: String
  } deriving (Eq)

data Action
  = Swap
  | ComponentAction !C.ActionIdx
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
initialModel = Model (C.Component A.initialModel False) "Additive"

initialModel2 :: Model
initialModel2 = Model (C.Component M.initialModel False) "Multiplicative"

additivePa :: C.PublicActions Action
additivePa = C.PublicActions {C.toParent = ComponentAction, C.click = NoOp}

updateModel :: Action -> Model -> Effect Action Model
updateModel (ComponentAction act) m@Model {..} = do
  addModel <- C.updateModel additive additivePa act
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
    , C.viewModel additive additivePa
    ]
