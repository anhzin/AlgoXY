module Klotski where

import qualified Data.Map as M
import Data.Ix
import Data.List (sort)
import Debug.Trace (trace)

-- `Heng Dao Li Ma' Layout
--  1 A A 2
--  1 A A 2
--  3 4 4 5
--  3 7 8 5
--  6 0 0 9

type Point = (Integer, Integer)
type Layout = M.Map Integer [Point]
type Move = (Integer, Point)

data Ops = Op Layout [Move] deriving (Eq, Show)

start = [(1, [(1, 1), (2, 1)]),
         (2, [(1, 4), (2, 4)]),
         (3, [(3, 1), (4, 1)]),
         (4, [(3, 2), (3, 3)]),
         (5, [(3, 4), (4, 4)]),
         (6, [(5, 1)]), (7, [(4, 2)]), (8, [(4, 3)]), (9, [(5, 4)]),
         (10, [(1, 2), (1, 3), (2, 2), (2, 3)])]

layout = sort . map sort . M.elems

mirror = M.map (map (\ (y, x) -> (y, 5 - x)))

solve :: [Ops] -> [[[Point]]]-> [Move]
solve [] _ = [] -- no solution
solve (Op x seq : cs) visit | M.lookup 10 x == Just [(4, 2), (4, 3), (5, 2), (5, 3)] = reverse seq
                            | otherwise = solve (trace ((show $ length q) ++"   "++ (show $ length seq)) q) visit'
  where
    ops = expand x visit
    visit' = map (layout . move x) ops ++ visit
    q = cs ++ [Op (move x op) (op:seq) | op <- ops ]

expand :: Layout -> [[[Point]]] -> [Move]
expand x visit = [(i, d) | i <-[1..10], d <- [(0, -1), (0, 1), (-1, 0), (1, 0)],
                           valid i d, (layout $ move x (i, d)) `notElem` visit] where
  valid i d = all (\ p -> let p' = shift p d in
                    inRange ((1, 1), (5, 4)) p' &&
                    (M.keys $ M.filter (elem p') x) `elem` [[i], []])
              (maybe [] id $ M.lookup i x)
  unique i d = let mv = move x (i, d) in all (`notElem` visit) (map layout [mv, mirror mv])

move x (i, d) = M.update (Just . map (flip shift d)) i x

shift (y, x) (dy, dx) = (y + dy, x + dx)

klotski s0 = let x = M.fromList s0 in solve [Op x []] [layout x]

-- [(6,(0,1)),(3,(1,0)),(4,(0,-1)),(8,(-1,0)),(9,(0,-1)),(5,(1,0)),(8,(0,1)),(4,(0,1)),(3,(-1,0)),(6,(0,-1)),(9,(0,-1)),(5,(0,-1)),(8,(1,0)),(4,(0,1)),(7,(-1,0)),(8,(1,0)),(9,(-1,0)),(6,(0,1)),(3,(1,0)),(7,(0,-1)),(4,(0,-1)),(2,(1,0)),(2,(1,0)),(10,(0,1)),(1,(0,1)),(7,(-1,0)),(3,(-1,0)),(6,(0,-1)),(7,(-1,0)),(3,(-1,0)),(9,(0,-1)),(5,(0,-1)),(8,(0,-1)),(2,(1,0)),(4,(0,1)),(5,(-1,0)),(6,(0,1)),(8,(-1,0)),(6,(0,1)),(5,(1,0)),(1,(1,0)),(7,(0,1)),(3,(-1,0)),(9,(-1,0)),(5,(0,-1)),(1,(1,0)),(1,(1,0)),(9,(0,1)),(9,(-1,0)),(4,(0,-1)),(2,(-1,0)),(4,(0,-1)),(6,(0,1)),(8,(1,0)),(2,(0,-1)),(6,(-1,0)),(8,(0,1)),(2,(1,0)),(4,(0,1)),(3,(1,0)),(4,(0,1)),(1,(-1,0)),(7,(0,-1)),(9,(-1,0)),(1,(-1,0)),(2,(0,-1)),(6,(0,-1)),(6,(1,0)),(4,(1,0)),(10,(1,0)),(9,(0,1)),(7,(0,1)),(3,(-1,0)),(5,(-1,0)),(9,(0,1)),(7,(0,1)),(1,(-1,0)),(2,(-1,0)),(6,(0,-1)),(6,(0,-1)),(8,(0,-1)),(8,(0,-1)),(4,(1,0)),(10,(1,0)),(7,(1,0)),(7,(0,1)),(1,(0,1)),(2,(-1,0)),(2,(-1,0)),(10,(0,-1)),(7,(1,0)),(7,(1,0)),(9,(1,0)),(9,(1,0)),(1,(0,1)),(2,(0,1)),(3,(0,1)),(5,(-1,0)),(5,(-1,0)),(10,(0,-1)),(7,(0,-1)),(7,(-1,0)),(4,(-1,0)),(8,(0,1)),(6,(0,1)),(8,(0,1)),(6,(0,1)),(10,(1,0)),(7,(0,-1)),(7,(0,-1)),(9,(0,-1)),(9,(0,-1)),(4,(-1,0)),(6,(-1,0)),(6,(0,1)),(10,(0,1))]