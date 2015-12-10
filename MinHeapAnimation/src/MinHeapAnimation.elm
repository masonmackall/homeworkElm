module MinHeapAnimation where

{-|
  Show min heap animations.
-}
import Graphics.Collage as Collage
import Graphics.Element as Element
import Graphics.Element exposing (Element)
import Graphics.Input as Input
import Signal as Signal
import Signal exposing (Signal)
import Time as Time
import Time exposing (Time)

import BinaryHeap.BinaryHeap as BinaryHeap
import BinaryHeap.Model as BinaryHeapModel
import BinaryHeap.Types as BinaryHeapTypes
import BinaryHeap.Viewer as BinaryHeapViewer
import Circle exposing (Circle, makeCircle)
import Global
import Types exposing (..)
import UI.Button as Button

main : Signal Element
main = Signal.map view modelAtFrame

--main : Element
--main = Element.show <| Box.move {x=1, y=0} <| makeBox {x=1, y=1}

type alias Model = {
    circle : Circle
  , heap : BinaryHeapTypes.Model
  }

makeHeap : List Int -> BinaryHeapTypes.Model
makeHeap xs = BinaryHeapModel.make <| makeHeapInternal xs

makeHeapInternal : List Int -> BinaryHeap.Heap
makeHeapInternal xs = case xs of
  [] -> BinaryHeap.empty
  x::xs' -> BinaryHeap.insert x <| makeHeapInternal xs'


initModel : Model
initModel =
     {
       circle = makeCircle { x = 0, y = 10 }
     , heap = makeHeap [1..50]
     }

fps : Signal Time
fps = Time.fps 30

type alias Frame = {
    fps : DeltaTime
  , insert : Bool
  }

makeFrame : DeltaTime -> Bool -> Frame
makeFrame dt insert = { fps = dt, insert = insert }

buttonClickedPerFrame : Signal a -> Signal Bool
buttonClickedPerFrame buttonSignal =
  let afterButton = Signal.foldp (\_ _ -> True) False buttonSignal
      afterFps = Signal.foldp (\_ _ -> False) False fps
  in
    Signal.sampleOn fps afterFps

inputEvent : Signal Frame
inputEvent =
  let insert = buttonClickedPerFrame (.signal Button.message)
      merged = Signal.map2 makeFrame fps insert
  in
    Signal.sampleOn fps merged

modelAtFrame : Signal Model
modelAtFrame = Signal.foldp (\t model -> updateModel t model) initModel fps

updateModel : DeltaTime -> Model -> Model
updateModel dt prevModel = {
    circle = prevModel.circle
  , heap = BinaryHeapModel.update dt prevModel.heap
  }

view : Model -> Element
view {circle, heap} =
  let tree =
        Collage.collage Global.width Global.height [
          circle.view
        , BinaryHeapViewer.view heap
        ]
      button =
        Input.button
          (Signal.message
            (.address Button.message)
            Button.Nothing)
          "insert"
    in
      Element.beside tree button

{-|
 Binary heap animation.
 bubbleDown
 bubbleUp

 deleteMin :
 1: take last element as x
 2: set first element to x
 3: bubble down from first element

 bubbleDown :
 1: compar i and two children
 2: find minimum of i and two children
 3: if i is minimum then exit
    else swap minimum and i
-}
