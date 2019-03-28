module Parser
where

import Util
import Data.Maybe
import InferenceDataType

-- Definire Program

initEmptyProgram :: Program
initEmptyProgram = undefined

getVars :: Program -> [[String]]
getVars = undefined 

getClasses :: Program -> [String]
getClasses = undefined

getParentClass :: String -> Program -> String
getParentClass = undefined

getFuncsForClass :: String -> Program -> [[String]]
getFuncsForClass = undefined

-- Instruction poate fi orice considerati voi
parse :: String -> [Instruction]
parse = undefined

interpret :: Instruction -> Program -> Program
interpret = undefined

infer :: Expr -> Program -> Maybe String
infer = undefined
