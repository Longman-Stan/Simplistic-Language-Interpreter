module ClassState
where

import qualified Data.Map as Map

-- Utilizat pentru a obține informații despre Variabile sau Funcții
data InstrType = Cls | Var | Func | FuncCl | Infer deriving (Show, Eq)

data Instruction = Instruction InstrType [String] deriving Eq

unroll::[String]->String
unroll s = foldr (\x y -> " "++x++y) "" s 

instance Show Instruction where
    show (Instruction Cls s) = "Cls"++(unroll s)
    show (Instruction Var s) =  "Var "++(unroll s)
    show (Instruction Func s) = "Func"++(unroll s)
    show (Instruction Infer s) = "Infer"++(unroll s)
    show (Instruction FuncCl s) = "Func with class "++(unroll s)
 
data ClassState = ClassState (Map.Map [String] Instruction) deriving (Show,Eq)

-- Definire ClassState

initEmptyClass :: ClassState
initEmptyClass = ClassState Map.empty

insertIntoClass :: ClassState -> InstrType -> [String] -> ClassState
insertIntoClass (ClassState map) Var (nume:tip:[])= ClassState ( Map.insert (nume:tip:[]) (Instruction Var (nume:tip:[]) ) map)
insertIntoClass (ClassState map) Func (nume:tip:rest) = ClassState ( Map.insert (nume:rest) (Instruction Func (tip:nume:rest) ) map)

filterVar::Instruction->Bool
filterVar (Instruction Var _) = True
filterVar (Instruction Func _) = False
 
filterFunc::Instruction->Bool
filterFunc (Instruction Var _) = False
filterFunc (Instruction Func _) = True

getVar::Instruction->[[String]]->[[String]]
getVar (Instruction Func sir) s=s
getVar (Instruction Var sir) s=sir:s

getFunc::Instruction->[[String]]->[[String]]
getFunc (Instruction Func [] ) s=[]
getFunc (Instruction Func (a:[]) ) s=[]
getFunc (Instruction Func (b:a:[]) ) s=[a,b]:s
getFunc (Instruction Func (b:a:c) ) s=(a:b:c):s
getFunc (Instruction Var sir) s=s

getValues :: ClassState -> InstrType -> [[String]]
getValues (ClassState map) Var = foldr getVar [] map
getValues (ClassState map) Func = foldr getFunc [] map

