module Q1Ans where

-- Model solution (see the slides)
-- Last update: 16 Oct, 12:20.
--
-- Corrections since the lecture:
-- - Changed dhp dog == 0 and mhp mon == 0 to <= 0 in both
-- - Changed implementation of Ord to be more explicit for every possibility

import Data.Maybe (catMaybes)
import Data.Tree ( Tree(..), drawTree ) -- This is needed for the last section
import Data.List (intercalate)        -- This is needed for the last section

-- A room has contents, and might branch into two more rooms.
-- The wizard promised we won't ever have a cycle (rooms can't connect to previous rooms).
-- Therefore, Room is a _tree_ datastructure
data Room = Room RoomContents (Maybe Room) (Maybe Room) deriving Show
data RoomContents = Fight Monster | Heal Int | Cage Rat | Empty | Escape deriving Show          -- added Cage

-- Our dog :)
data Dog = Dog { dhp :: Int, ddmg :: Int, rat :: Maybe Rat} deriving Show           -- added dog possibly having a rat
data Rat = Rat { ratName :: String } deriving Show          -- our added Rat

-- A monster! :o
data Monster = Monster { mhp :: Int, mdmg :: Int } deriving Show

-- What the result of a dog entering a room could be
-- They can either:
-- 1. Victory: escape
-- 2. Death: die
-- 3. Continue: be able to continue in the dungeon; alive but not free yet.
data VisitResult = Victory | Death | Continue Dog deriving Show

-- We need to be able to compare the results of dogs entering rooms
-- That way, we can say whether going left is a _better choice_ than right or not
-- Once we have that, we can begin to find out the overall best path through the dungeon.
-- We define Ord here such that x <= y means that x is a _worse result_ than y for our dog
instance Ord VisitResult where
    a <= b
        -- == obviously implies <=, since <= is defined as < or ==
        | a == b = True      -- matches a <= b IF a == b.

        -- If both paths continue, the best one is when the dog has the most health
        | (Continue dog) <- a, (Continue dog') <- b = (dhp dog, hasRat dog) <= (dhp dog', hasRat dog')

        -- Now we've ruled out == from <=, we just need to implement < for the rest

        -- Death is worse than anything else, and anything is better than Death
        | Death <- a = True  -- matches Death <= any
        | Death <- b = False -- matches any <= Death

        -- Victory is better than anything else, and anything is worse than Victory
        | Victory <- b = True  -- matches any <= Victory
        | Victory <- a = False -- matches Victory <= any

        -- DIFFERENCE FROM THE LECTURE: I got rid of the otherwise case to make it
        -- easier to see what is happening here.
    

-- To implement Ord we also need to implement Eq.
-- Our ddmg shouldn't ever change, so we only compare HP here
-- And we won't compare dogs from different dungeons, so we don't 
-- need to worry about dogs with different dmg values being compared
hasRat :: Dog -> Bool
hasRat dog = case rat dog of
    Just _ -> True
    Nothing -> False

instance Eq VisitResult where
    Victory      == Victory      = True
    Death        == Death        = True
    (Continue a) == (Continue b) = (dhp a) == (dhp b) && hasRat a == hasRat b
    _ == _                       = False

-- Find the result of our dog fighting a monster
fight :: Dog -> Monster -> VisitResult
fight dog mon
    | dhp dog <= 0 = Death
    | mhp mon <= 0 = Continue dog
    | otherwise    = fight dog' mon'
        where
    dog' = (dog { dhp = (dhp dog) - (mdmg mon) })
    mon' = (mon { mhp = (mhp mon) - (ddmg dog) })

-- Find the result of our dog visiting a room.
-- This _only_ processes what is inside THAT room. Not the room's children (left + right room)
-- This is the CONQUER part of our divide and conquer approach.
visitRoom :: Dog -> RoomContents -> VisitResult
visitRoom dog room = go room
    where 
    go (Fight monster) = fight dog monster
    go (Heal hp)       = Continue dog { dhp = (dhp dog) + hp }
    go Escape          = Victory
    go Empty           = Continue dog
    go (Cage rat)      = Continue dog { rat = Just rat}

-- Find the result of our dog visiting a room AND its children rooms.
-- This essentially solves the subtree rooted at the given room.
crawl :: Dog -> Room -> VisitResult
crawl dog (Room this left right) = soln
    where 
    soln = case (visitRoom dog this) of
                Continue dog' -> fork dog' left right
                Victory       -> Victory
                Death         -> Death

-- Find the result of our dog visiting ONLY the room's children. It is the counterpart to visitRoom.
-- Notice how crawl = fork + visitRoom.
-- This is our DIVIDE part of our divide and conquer approach.
fork :: Dog -> Maybe Room -> Maybe Room -> VisitResult
fork dog leftRoom rightRoom = bestPath
    where
  -- The best path for the dog is the _highest scoring_ valid path.
  -- This uses our instance Ord VisitResult where
  bestPath   = maximum validPaths

  -- Our possible valid paths.
  -- An _invalid_ path would be Nothing here, and represents e.g. going to the left room,
  -- if there _is_ no left room. catMaybes filters these out into paths that CAN be done.
  validPaths = catMaybes [leftFirst,     rightFirst,      leftOnly,     rightOnly,   Just $ Continue dog]
  --                     ^^^^^^^^^^^^^^^^^^^^^^           ^^^^^^^^^^^^^^^^^^^^^^^^   ^^^^^^^^^^^^^^^^^^^
  --                     visit both child rooms             visit just one child     don't visit children
  --                   (left -> right,  right -> left)    (left)          (right)

  -- Define the valid paths
  leftFirst  = fmap (uncurry $ crawlBoth dog) (both leftRoom rightRoom)
  rightFirst = fmap (uncurry $ crawlBoth dog) (both rightRoom leftRoom)
  leftOnly   = fmap (crawl dog) leftRoom
  rightOnly  = fmap (crawl dog) rightRoom


-- Find the result of our dog visiting the first room and THEN the second room, in sequence.
crawlBoth :: Dog -> Room -> Room -> VisitResult
crawlBoth dog first second = sequenced
    where
    sequenced = case (crawl dog first) of
                    Continue dog' -> crawl dog' second
                    Victory       -> Victory
                    Death         -> Death

-- Convert two maybes into one. We get a Just out when both maybes are Just.
both :: Maybe a -> Maybe b -> Maybe (a, b)
both (Just a) (Just b) = Just (a, b)
both _        _        = Nothing
