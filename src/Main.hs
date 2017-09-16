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
  { component :: C.Component -- The swappable component
  , currentModel :: String -- The rest of the main model
  } deriving (Eq)

data Action
  = Swap
  | ComponentAction !C.ActionIdx -- Actions to get passed down to the components
  | NoOp

main :: IO ()
main = do
  startApp App {model = additiveModel, initialAction = Swap, ..}
  where
    update = updateModel
    view = display
    events = defaultEvents
    subs = []

-- Model with additive component
additiveModel :: Model
additiveModel = Model (C.Component A.initialModel False) "Additive"

-- Model with multiplicative component
multiplicativeModel :: Model
multiplicativeModel = Model (C.Component M.initialModel False) "Multiplicative"

-- Creating a PublicActions for both components
componentPa :: C.PublicActions Action
componentPa = C.PublicActions {C.toParent = ComponentAction, C.click = NoOp}

updateModel :: Action -> Model -> Effect Action Model
updateModel (ComponentAction act) m@Model {..}
  -- Update the component's model,
 = do
  addModel <- C.updateModel component componentPa act
  -- Update the component in the main model
  noEff m {component = addModel}
updateModel Swap (Model _ "Additive") = noEff multiplicativeModel
updateModel Swap (Model _ "Multiplicative") = noEff additiveModel
updateModel NoOp m = noEff m

-- Call the 'viewModel' to draw the component where you want it.
display :: Model -> View Action
display m@Model {..} =
  div_
    []
    [ button_ [onClick Swap] [text "Swap"]
    , p_ [] [text . pack $ "Model : ", b_ [] [text . pack $ currentModel]]
    , C.viewModel component componentPa
    ]
