module BinaryHeap.BinaryHeap
  (Heap, empty, isEmpty, findMin, insert, deleteMin, merge
  , getInternalArray) where

import Array as A

type alias InternalHeap = A.Array Int
type Heap = WrapHeap (A.Array Int)

getInternalArray : Heap -> A.Array Int
getInternalArray (WrapHeap a) = a

fromJust : Maybe a -> a
fromJust mx = case mx of
  Just x -> x
  Nothing -> Debug.crash "fromJust: Nothing"

justGet : Int -> A.Array a -> a
justGet i a = fromJust (A.get i a)

pop : A.Array a -> A.Array a
pop a = A.slice 0 (A.length a - 1) a 

swap : Int -> Int -> A.Array a -> A.Array a
swap i j a =
  a |> A.set i (justGet j a) |> A.set j (justGet i a)

insert : Int -> Heap -> Heap
insert x (WrapHeap a) =
  let n  = A.length a
      a' = A.push x a in
    WrapHeap (bubbleUp n a')

bubbleUp : Int -> InternalHeap -> InternalHeap
bubbleUp i a =
  if i == 0
     then a
     else
        let j   = (i-1) // 2
            ch  = justGet i a
            par = justGet j a in
        if par <= ch
        then a
        else a |> swap i j |> bubbleUp j

-- BUGGY DELETEMIN:
--
-- type Dir = Left | Right
-- 
-- pathTo : Int -> List Dir
-- pathTo =
--   let foo i = if
--         | i == 0         -> []
--         | i `rem` 2 == 1 -> Left  :: foo ((i-1) // 2)
--         | otherwise      -> Right :: foo ((i-1) // 2)
--   in
--   List.reverse << foo
-- 
-- deleteMin : Heap -> Maybe Heap
-- deleteMin (WrapHeap a) =
--   let n = A.length a in if
--     | n == 0    -> Nothing
--     | otherwise -> a |> A.set 0 maxInt
--                      |> bubbleDown (pathTo (n-1)) 0
--                      |> pop
--                      |> WrapHeap
--                      |> Just
-- 
-- go : Int -> Dir -> Int
-- go i dir =
--   case dir of
--     Left  -> 2*i + 1
--     Right -> 2*i + 2
-- 
-- bubbleDown : List Dir -> Int -> InternalHeap -> InternalHeap
-- bubbleDown path i a =
--   case path of
--     [] -> a
--     leftOrRight :: path' ->
--       let j = i `go` leftOrRight in
--       a |> swap i j |> bubbleDown path' j

deleteMin : Heap -> Maybe Heap
deleteMin (WrapHeap a) =
  let n = A.length a in
  if n == 0
     then Nothing
     else let x = justGet (n-1) a in
                     a |> pop
                       |> A.set 0 x
                       |> bubbleDown 0
                       |> WrapHeap
                       |> Just

bubbleDown : Int -> InternalHeap -> InternalHeap
bubbleDown i a =
  let n = A.length a in
  if i >= n
     then a
     else
         let (j, k) = (2*i + 1, 2*i + 2) in
         let i'  = if j < n && justGet j a < justGet i  a then j else i  in
         let i'' = if k < n && justGet k a < justGet i' a then k else i' in
         if i == i'' then a
            else a |> swap i i'' |> bubbleDown i''

empty : Heap
empty = WrapHeap A.empty

isEmpty : Heap -> Bool
isEmpty (WrapHeap a) = A.length a == 0

findMin : Heap -> Maybe Int
findMin (WrapHeap a) = A.get 0 a

merge : Heap -> Heap -> Heap
merge _ _ =  empty   -- triggering a run-time error
