{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE EmptyDataDecls        #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE GADTs                 #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell       #-}


-- | Cubix tutorial: Exercise 1
--
-- In this exercise, you'll create a small language in the
-- datatypes a la carte style used by Cubix.

module Main where

import Cubix.Essentials

------------------------------------------------------------------------------

__TODO__ :: a
__TODO__ = undefined

---------------------------------------------------------

-- | PART 1
-- In this part, you'll define language fragments for a simple "Imp" language, called "Imp1".

-- | PART 1a
--
-- Define sorts and language fragments equivalent to the below set of mutually-recursive datatypes.
--
-- Each language fragment should have no reference to the others.
-- You should require *no* pre-existing definitions for this.
--
--------------------------------------------
--
-- data VarRef = Var String
--             | FieldRef VarRef String
--
-- data Statement = Assign VarRef Exp
--                | Seq Statement Statement
--
-- data Exp = Mul Exp Exp
--          | IntExp Int
--          | VarExp VarRef


data StatementL -- The first sort is written for you

data VarRefL
data ExpL

data VarRef e l where
  Var      :: String              -> VarRef e VarRefL
  FieldRef :: e VarRefL -> String -> VarRef e VarRefL

data Statement e l where
  Assign :: e VarRefL -> e ExpL          -> Statement e StatementL
  Seq    :: e StatementL -> e StatementL -> Statement e StatementL

data Exp e l where
  Mul    :: e ExpL -> e ExpL -> Exp e ExpL
  IntExp :: Int              -> Exp e ExpL
  VarExp :: e VarRefL        -> Exp e ExpL


-- | PART 1b
--
-- Update and uncomment the below definition to refer to the (nonempty) datatypes you defined in part 1.
-- This Template Haskell generates a host of boilerplate definitions for your functions,
-- including instances for `HTraversable` (generic tree traversal functionality), `EqHF` and `ShowHF`
-- (which allow you to use `(==)` and `show` on terms of the `Imp1` type defined below),
-- and the "smart constructors" `iAssign`, `iSeq`, etc (which we'll explain more in Part 3))

-- deriveAll [''Typename1, ''Typename2]

deriveAll [''VarRef, ''Statement, ''Exp]


----------------------------------------------

-- | PART 2
--
-- In this part, you'll assemble the language fragments from Part 1 into a definition
-- for version 1 of an Imp language


-- | PART 2a
--
-- Define `Imp1Sig` to be the signature of your "Imp1" language, as a type-level list containing the definitions
-- from part 1

-- type Imp1Sig = '[FILL, THIS, IN]

type Imp1Sig = '[VarRef, Statement, Exp]

-- | PART 2b
--
-- Define the `Imp1` type as `Term`'s of signature `Imp1Sig`
--
-- Then the type @Imp1 StatementL@ should be isomorphic
-- to the mutually-recursive definition of @Statement@ given in Part 1

--type Imp1 l = () -- placeholder definition

type Imp1 = Term Imp1Sig

---------------------------------------------------------

-- | Part 3
-- Once you've finished parts 1 and 2, uncomment the definition of `exampleProgram` below.
-- Then running `main` should print:
-- @
-- (Seq (Assign (Var "x") (Mul (IntExp 1) (IntExp 1)))
--      (Assgn (Var "y") (VarExp (Var "x"))))
-- @
--
-- Note that this is identical to what you'd get from running `show` on a term
-- constructed by the vanilla mutually-recursive datatypes.

exampleProgram :: Imp1 StatementL
--exampleProgram = __TODO__
exampleProgram = iAssign (iVar "x") (iMul (iIntExp 1) (iIntExp 1))
                 `iSeq`
                 iAssign (iVar "y") (iVarExp (iVar "x"))

main :: IO ()
main = putStrLn $ show exampleProgram


-- | Let's talk more about smart constructors
--
-- Here's an example smart constructor that should be generated by `deriveAll`
--
-- @
-- iAssign :: (Statement :-<: fs) => Term fs VarRefL -> Term fs ExpL -> Term fs StatementL
-- @
--
-- The constraint @(Statement :-<: fs)@ means "@fs@ is any signature that contains `Statement`"
--
-- Then a @Term fs ExpL@ means "an expression in any language that contains the `Statement` fragment."
--
-- That means that `iAssign` lets you construct assignment nodes in any language that has them!
--
-- The downside is that the typechecker will need more information to figure out what language
-- you're trying to create terms for. You can try inlining `exampleProgram` into `main`. The
-- typechecker should complain that it can't infer @fs@.


-- | BONUS: PART 4
--
-- Want a sneak preview of the power of Cubix's multi-language modularity?
--
-- Import "Cubix.Language.Parametric.Syntax" to get Cubix's generic fragments.
--
-- * Beware that some names in that package conflict with names defined in this file. You'll
--   need to use an "import ... hiding" declaration to avoid importing the conflicting names.
--
-- Change all occurrences of `String` to @e IdentL@.
--
-- Add the `Ident` fragment to `Imp1Sig`. Now `Imp1` is defined as
-- a mixture of the language-specific fragments defined in this file, and the generic `Ident` fragment.
-- You will need to change @iVar "x"@ into @iVar (iIdent "x")@ and similar.
--
-- You can now run the `vandalize` transformation from the cubix-sample-app on your language!
-- (Copy its definition into this file to run.)