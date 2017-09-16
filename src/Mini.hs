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

newtype Component1 =
  Component1 String
  deriving (Eq, Show)

newtype Component2 =
  Component2 Int
  deriving (Eq, Show)

class Component a where
  displayModel :: a -> View action

instance Component Component1 where
  displayModel (Component1 s) = p_ [] [text . pack . show $ s]

instance Component Component2 where
  displayModel (Component2 s) = p_ [] [text . pack . show $ s]

initialModel = Model 0 $ Component1 "World"

initialModel2 = Model 1 $ Component2 2017

data Model =
  forall a. (Component a) =>
            Model Int
                  a

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
