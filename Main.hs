{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE MultiWayIf #-}
{-# LANGUAGE BangPatterns #-}

module Main where

import Data.Function
import qualified Data.Map as M
import Data.Monoid

import Miso
import Miso.String

data Action
  = Time !Double
  | NoOp

foreign import javascript unsafe "$r = performance.now();" now ::
               IO Double

main :: IO ()
main = do
  time <- now
  let m = mario {time = time}
  startApp App {model = m, initialAction = NoOp, ..}
  where
    update = updateMario
    view = display
    events = defaultEvents
    subs = []

data Model = Model
  { time :: !Double
  , delta :: !Double
  , deltas :: ![Double]
  } deriving (Show, Eq)

data Direction
  = L
  | R
  deriving (Show, Eq)

mario :: Model
mario = Model {time = 0, delta = 0, deltas = []}

updateMario :: Action -> Model -> Effect Action Model
updateMario NoOp m = m <# (Time <$> now)
updateMario (Time newTime) m = step newModel
  where
    newModel =
      m
      { delta = max (delta m) (newTime - time m)
      , deltas = delta m : deltas m
      , time = newTime
      }

step :: Model -> Effect Action Model
step m = m <# (Time <$> now)

display :: Model -> View action
display m@Model {..} =
  div_ [] [p_ [] [text . pack . show $ time], p_ [] [text . pack . show $delta]]
