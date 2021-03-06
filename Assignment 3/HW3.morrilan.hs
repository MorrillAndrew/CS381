--------------------------------------------------
----- Group Names: Andrew Morrill, Pierre-Louis Sixdenier, Ehmar Khan
----- Group ONIDs: morrilan,       sixdenip,               khaneh
----- Date: 2/13/18       			Class: CS 381
----- Main File Name: HW3.morrilan.hs
----- Purpose: Implements Programs
----- Completion: 100% requirements done, no time for EC
--------------------------------------------------

module HW3 where

import MiniMiniLogo
import Render


--
-- * Semantics of MiniMiniLogo
--

-- NOTE:
--   * MiniMiniLogo.hs defines the abstract syntax of MiniMiniLogo and some
--     functions for generating MiniMiniLogo programs. It contains the type
--     definitions for Mode, Cmd, and Prog.
--   * Render.hs contains code for rendering the output of a MiniMiniLogo
--     program in HTML5. It contains the types definitions for Point and Line.

-- | A type to represent the current state of the pen.
type State = (Mode,Point)

-- | The initial state of the pen.
start :: State
start = (Up,(0,0))

-- | A function that renders the image to HTML. Only works after you have
--   implemented `prog`. Applying `draw` to a MiniMiniLogo program will
--   produce an HTML file named MiniMiniLogo.html, which you can load in
--   your browswer to view the rendered image.
draw :: Prog -> IO ()
draw p = let (_,ls) = prog p start in toHTML ls


-- Semantic domains:
--   * Cmd:  State -> (State, Maybe Line)
--   * Prog: State -> (State, [Line])


-- | Semantic function for Cmd.
--   
--   >>> cmd (Pen Down) (Up,(2,3))
--   ((Down,(2,3)),Nothing)
--
--   >>> cmd (Pen Up) (Down,(2,3))
--   ((Up,(2,3)),Nothing)
--
--   >>> cmd (Move 4 5) (Up,(2,3))
--   ((Up,(4,5)),Nothing)
--
--   >>> cmd (Move 4 5) (Down,(2,3))
--   ((Down,(4,5)),Just ((2,3),(4,5)))
--
-- cmd :: Cmd -> State -> (State, Maybe Line)
-- cmd (Pen Up)   (_, cord)    = ((Up, cord),Nothing)  
-- cmd (Pen Down) (_, cord)    = ((Down,cord),Nothing)
-- cmd (Move x y) (Up, cord)   = ((Up,(x,y)),Nothing)
-- cmd (Move x y) (Down, cord) = ((Down,(x,y)),Just ((cord),(x,y))) -- From cord to move x y

--  Uses cases to divide up the different constructor combinations.

cmd :: Cmd -> State -> (State, Maybe Line)
cmd (Pen Up)   = \s -> case s of
                         (_, cord) -> ((Up, cord), Nothing)  
cmd (Pen Down) = \s -> case s of
                         (_, cord) -> ((Down,cord), Nothing)
cmd (Move x y) = \s -> case s of
                         (Up, _)      -> ((Up,(x,y)), Nothing)
                         (Down, cord) -> ((Down,(x,y)), Just ((cord),(x,y))) -- From cord to move x y
 
-- | Semantic function for Prog.
--
--   >>> prog (nix 10 10 5 7) start
--   ((Down,(15,10)),[((10,10),(15,17)),((10,17),(15,10))])
--
--   >>> prog (steps 2 0 0) start
--   ((Down,(2,2)),[((0,0),(0,1)),((0,1),(1,1)),((1,1),(1,2)),((1,2),(2,2))])
-- 
-- Base Case: no Cmds, return the state with Nothing
-- send first Cmd to cmd along with state, then return back state and Maybe line.
-- f (g x) = (f . g) x
--  DOESNT WORK
-- prog :: Prog -> State -> (State, [Line])
-- prog [] = \s -> (s, []) 
-- prog (c : cl) =  \s -> case cmd c s of 
--                          (state, Nothing) -> prog cl state []
--                          (state, Just a)  -> prog cl state a

--  Created helper function because we couldnt figure it out all day
--   Helper recieves an extra argument making the solution trivial.
prog :: Prog -> State -> (State, [Line])
prog [] = \s -> (s, []) 
prog p = \s ->  progHelper p [] s

progHelper :: Prog -> [Line] -> State -> (State, [Line])
progHelper [] l = \s -> (s, l) 
progHelper (c : cl) l =  \s -> case cmd c s of 
                         (state, Nothing) -> progHelper cl l state  
                         (state, Just a)  -> progHelper cl (l ++ [a]) state

-- prog (c : cl) = prog cl . cmd c

-- prog :: Prog -> State -> (State, [Line])
-- prog [] s = (s, []) 
-- prog (c : cl) s = case cmd c s of 
--                     (state, Nothing) -> prog cl state
--                     (state, Just a) ->  (prog cl state, [a])




--
-- * Extra credit
--

-- | This should be a MiniMiniLogo program that draws an amazing picture.
--   Add as many helper functions as you want.
amazing :: Prog
amazing = (nix 10 10 5 7) 
