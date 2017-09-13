{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE MultiWayIf #-}
{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE ExistentialQuantification #-}

module Main where

import Data.Function
import qualified Data.Map as M
import Data.Monoid

import Miso
import Miso.String

data Action
  = Swap
  | NoOp

main :: IO ()
main = do
  startApp App {model = initialModel, initialAction = Swap, ..}
  where
    update = updateModel
    view = display
    events = defaultEvents
    subs = []

newtype SubModel1 =
  SubModel1 String
  deriving (Eq, Show)

newtype SubModel2 =
  SubModel2 Int
  deriving (Eq, Show)

class SubModel a where
  displayModel :: a -> View action

instance SubModel SubModel1 where
  displayModel (SubModel1 s) = p_ [] [text . pack . show $ s]

instance SubModel SubModel2 where
  displayModel (SubModel2 s) = p_ [] [text . pack . show $ s]

initialModel = Model 0 $ SubModel1 "World"

initialModel2 = Model 1 $ SubModel2 2017

data Model = forall a. (SubModel a) => Model Int a

instance Eq Model where
  Model x _ == Model y _ = x == y
  Model x _ /= Model y _ = x == y

updateModel :: Action -> Model -> Effect Action Model
updateModel Swap (Model 0 _) =
  initialModel2 <# do
    putStrLn "Swapping to 1"
    pure NoOp
updateModel Swap (Model 1 _) =
  initialModel <# do
    putStrLn "Swapping to 0"
    pure NoOp
updateModel NoOp m = noEff m

display :: Model -> View Action
display (Model _ m) =
  div_
    []
    [ button_ [onClick Swap] [text "Swap"]
    , p_ [] [text . pack $ "Model"]
    , displayModel m
    ]
