module InferenceDataType
where

-- Reprezentarea unei expresii
data Expr = Va String | FCall String String [Expr] deriving (Show)
