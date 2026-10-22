module Q1Ans where

-- Last updated 17 Oct
-- 
-- Corrections since 16 Oct
-- - Updated Ord for VisitResult because it was wrong. Now uses a tuple
-- - Updated question 1.6 "it picks up a rat if it doesn't already have one".
--   Q1 has only one rat so this doesn't make a difference.
-- - Updated question 1.5 so it says to impl Ord for VisitResult, not Dog
--   It is valid to implement Ord on Dog and use it in Ord on VisitResult,
--   but it's not _required_

-- Q1.1
data Rat = Rat { ratName :: String } deriving Show
-- Above this line, we have a COMPLETE solution for Q1.1 that scores full marks for that sub-question
-- i.e. if we submitted _only_ the lines above this comment, we would get 100% on that sub-question.
-- We only need the things below for later questions

-- Q1.2
data Dog = Dog { dhp :: Int, ddmg :: Int, rat :: Maybe Rat } deriving Show
-- Now we have a complete, 100% correct solution for Q1.2

-- Q1.3
data RoomContents = Fight Monster | Heal Int | Empty | Escape | Cage Rat deriving Show
-- copied without modification from skeleton
data Monster = Monster { mhp :: Int, mdmg :: Int } deriving Show
-- Now we have a complete, 100% correct solution for Q1.3

-- Q1.4
-- copied without modification from skeleton
data VisitResult = Victory | Death | Continue Dog deriving Show

-- isJust could also be imported from Data.Maybe and that would be allowed.
-- Knowing about its existence is the kind of thing practising will help with.
-- But, you can figure this out from first principles quite easily.
isJust :: Maybe a -> Bool
isJust Nothing = False
isJust (Just _) = True
hasRat dog = isJust (rat dog)

instance Eq VisitResult where
    Victory      == Victory      = True
    Death        == Death        = True
    (Continue a) == (Continue b) = (dhp a) == (dhp b) && hasRat a == hasRat b
    _ == _                       = False
-- Now we have a complete, 100% correct solution for Q1.4

-- Q1.5
instance Ord VisitResult where
    a <= b
      | a == b = True        -- matches a <= b IF a == b.

      -- Ord for tuple as used here compares the two first elems. If they are equal, it compares the second elems. So here the HP
      -- takes precedence over the amount of rats
      | (Continue dog) <- a, (Continue dog') <- b = (dhp dog, hasRat dog) <= (dhp dog', hasRat dog')
      | Death <- a = True    -- matches Death <= any
      | Death <- b = False   -- matches any <= Death
      | Victory <- b = True  -- matches any <= Victory
      | Victory <- a = False -- matches Victory <= any
-- Now we have a complete, 100% correct solution for Q1.5

-- Q1.6
visitRoom :: Dog -> RoomContents -> VisitResult
visitRoom dog room = go room
    where 
  go (Fight monster) = fight dog monster
  go (Heal hp)       = Continue dog { dhp = (dhp dog) + hp }
  go (Cage rat)      = Continue dog { rat = Just rat }
  go Escape          = Victory
  go Empty           = Continue dog

-- copied without modification from skeleton
fight :: Dog -> Monster -> VisitResult
fight dog mon
  | dhp dog <= 0 = Death
  | mhp mon <= 0 = Continue dog
  | otherwise    = fight dog' mon'
    where
  dog' = (dog { dhp = (dhp dog) - (mdmg mon) })
  mon' = (mon { mhp = (mhp mon) - (ddmg dog) })
-- Now we have a complete, 100% correct solution for Q1.6
