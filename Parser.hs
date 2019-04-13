module Parser
where


import Data.Maybe
import InferenceDataType
import ClassState
import qualified Data.Map as Map

data Class = Class String String ClassState deriving (Show,Eq)

getClassName::Class->String
getClassName (Class a b c)=a

getClassParent::Class->String
getClassParent (Class a b c) = b 

getClassState::Class->ClassState
getClassState (Class a b c) = c

insertInCls::Class->Instruction->Class
insertInCls (Class a b state) (Instruction tip args)= Class a b $ insertIntoClass state tip args

data Program = Program ( Map.Map String Class)

insertClass::Program->Class->Program
insertClass (Program map) cls = Program $ Map.insert (getClassName cls) cls map

-- Definire Program

initEmptyProgram :: Program
initEmptyProgram = Program $ Map.fromList [("Global",Class "Global" "Global" initEmptyClass)]

getVars :: Program -> [[String]]
getVars (Program map) = foldr (\x y-> (getValues (getClassState x) Var)++y) [] classlist
        where classlist = foldr (\x y->(snd x):y) [] (Map.toList map)

getClasses :: Program -> [String]
getClasses (Program map)= foldr (\x y->(fst x):y) [] (Map.toList map)

getFromMaybe (Just a)=a
getParentClass :: String -> Program -> String
getParentClass nume (Program map) = getClassParent(getFromMaybe ( Map.lookup nume map ))

accesClass::String->Program->Maybe Class
accesClass nume (Program mapa) = Map.lookup nume mapa

getFuncsForClass :: String -> Program -> [[String]]
getFuncsForClass nume (Program map)
    | zeClass==Nothing = []
    | otherwise = getValues (getClassState (getFromMaybe zeClass)) Func
        where zeClass = Map.lookup nume map

-- Instruction poate fi orice considerati voi
elimDuplicateWhites::String->String
elimDuplicateWhites [] = []
elimDuplicateWhites (a:[]) = (a:[])
elimDuplicateWhites (a:b:[])
    | a==' ' && b==' ' = []
    | otherwise = (a:b:[])
elimDuplicateWhites (a:b:c)
    | b /= ' ' = a:b:(elimDuplicateWhites c)
    | a==' '= elimDuplicateWhites (b:c)
    | otherwise = a:(elimDuplicateWhites (b:c))

elimWhites::String->String
elimWhites [] = []
elimWhites (a:b)
    | a==' ' = elimWhites b
    | otherwise = a:(elimWhites b)

elimFirstWhites::String->String
elimFirstWhites [] = []
elimFirstWhites (a:b)
    | a==' ' || a==':' = elimFirstWhites b
    | otherwise = a:b

first_word::String->String
first_word [] = []
first_word (a:c)
    | a == ' ' = []
    | a == ':' = []
    | a == '(' = []
    | a == '=' = []
    | a == '.' = []
    |otherwise = a:first_word(c)

rest_word::String->String
rest_word [] = []
rest_word (a:[]) = []
rest_word (a:b:c)
    | a == ' ' = if b=='=' then c else b:c
    | a == '(' = b:c
    | a == ':' = c
    | a == '=' = b:c
    |otherwise = rest_word (b:c)

split_lines::String->[String]
split_lines [] = []
split_lines ('\n':[])="":[]
split_lines (a:b)
    | a == '\n' = if (head so_far==[]) then so_far else []:so_far
    |otherwise = (a:(head so_far)):(tail so_far)
        where so_far = split_lines b

parseClass::String-> Instruction
parseClass str
    | rest == "" = Instruction Cls [elimWhites str,"Global"]
    | otherwise = Instruction Cls [ elimWhites(first_word (elimFirstWhites str)), elimWhites(rest_word rest) ]
        where rest = elimFirstWhites $ rest_word $ elimFirstWhites str

parseVar::String->Instruction
parseVar str = Instruction Var [ first_word (elimFirstWhites str) , elimFirstWhites rest ]
    where rest = elimFirstWhites $ rest_word $elimFirstWhites str 

get_params::String-> [String]
get_params [] = []
get_params ('(':r) = get_params r
get_params (')':[]) = []
get_params (a:')':[]) = (a:[]):[]
get_params (a:b)
    | a == ',' = []:so_far
    |otherwise = (a:(head so_far)):(tail so_far)
        where so_far = get_params b

parseFunc::String->Instruction
parseFunc str = Instruction FuncCl ([clasa,numele,ret_type]++(get_params $ elimWhites parametrii))
    where ret_type = first_word (elimFirstWhites str)
          clasa = first_word $ elimFirstWhites $ rest_word $elimFirstWhites str
          numele = first_word $ elimFirstWhites $ rest_word $ elimFirstWhites $ rest_word $elimFirstWhites str
          parametrii = rest_word $ elimFirstWhites $ rest_word $ elimFirstWhites $ rest_word $elimFirstWhites str
 
parseInfer::String->Instruction
parseInfer str = Instruction Infer [nume,exp]
    where nume = first_word $ elimFirstWhites str
          exp = elimFirstWhites $ rest_word $ elimFirstWhites str

parse_chooser::String->Instruction
parse_chooser str
    | fst_wd == "class" = parseClass rest
    | fst_wd == "newvar" = parseVar rest
	| fst_wd == "infer" = parseInfer rest
    | otherwise = parseFunc str
    where rest = elimFirstWhites $ rest_word $ str
          fst_wd = first_word $ str

parse :: String -> [Instruction]
parse str = foldr (\x y-> (parse_chooser x):y) [] $ split_lines $ elimDuplicateWhites $ str

-- Parsare expresie

isPoint::String->String
isPoint [] = []
isPoint (a:b)
	| a == '.' = b
	| otherwise = isPoint b

getBetweenCommas::String->Int->String
getBetweenCommas [] _ = []
getBetweenCommas (')':[]) x = []
getBetweenCommas ('(':b) x = '(':(getBetweenCommas b (x+1))
getBetweenCommas (',':b) x
    | x == 0 = []
	|otherwise = ',':so_far
    where so_far = getBetweenCommas b x
getBetweenCommas (')':b) x = ')':(getBetweenCommas b (x-1))
getBetweenCommas (' ':b) x = getBetweenCommas b x
getBetweenCommas (a:b) x = a:(getBetweenCommas b x)

afterComma::String->Int->String
afterComma [] _ = []
afterComma ('(':b) x = afterComma b (x+1)
afterComma (',':b) x
	| x == 0 = b
	| otherwise = afterComma b x
afterComma (')':b) x = afterComma b (x-1)
afterComma (a:b) x= afterComma b x

getParamsInfer::String->[String]
getParamsInfer [] = []
getParamsInfer s = (getBetweenCommas s 0):( getParamsInfer (afterComma s 0))

parseExpr::String->Expr
parseExpr s
    | rest == "" = Va s
	| otherwise = FCall (first_word s) (first_word (elimFirstWhites rest)) (map parseExpr parametrii)
    where rest = isPoint $ elimWhites s
          parametrii = getParamsInfer $ rest_word rest

-- Asta a fost parsarea

legitArguments::[String]->Program->Bool
legitArguments [] (Program mapa) = True
legitArguments (a:b) (Program mapa)
    | elem a classes == True = legitArguments b (Program mapa)
    | otherwise = False
    where classes = getClasses (Program mapa)

interpret :: Instruction -> Program -> Program
interpret (Instruction Cls (a:b:[])) prog
    | elem b classes ==True = insertClass prog $ Class a b initEmptyClass
    | otherwise = insertClass prog $ Class a "Global" initEmptyClass
    where classes = getClasses prog

interpret (Instruction Var (a:b:[])) (Program mapa)
    | elem b classes == True = ( Program  ( Map.insert "Global" (insertInCls (getFromMaybe zeClass) (Instruction Var (a:b:[]) ) ) mapa )) 
    | otherwise = (Program mapa)
    where classes = getClasses (Program mapa)
          zeClass = Map.lookup "Global" mapa

interpret (Instruction FuncCl (a:b:c:d)) (Program mapa)
    | elem a classes == True && elem c classes == True && (legitArguments d (Program mapa))==True = 
	  ( Program  ( Map.insert a (insertInCls (getFromMaybe zeClass) (Instruction Func (b:c:d) ) ) mapa )) 
    | otherwise = (Program mapa)
    where classes = getClasses (Program mapa)
          zeClass = Map.lookup a mapa
		 
interpret (Instruction Infer (a:b:[])) (Program mapa)
    | tip == Nothing = Program mapa
	| otherwise = Program ( Map.insert "Global" (insertInCls (getFromMaybe zeClass) (Instruction Var (a:(getFromMaybe tip):[]))) mapa)
    where tip = infer (parseExpr b) (Program mapa)
          zeClass = Map.lookup "Global" mapa

gaseste::String->[[String]]->Maybe String
gaseste s [] = Nothing
gaseste s ((x:y:[]):b) 
    |s==x = Just y
    |otherwise = gaseste s b

check_params::[Maybe String]->Bool
check_params [] = True
check_params (a:b) 
    | a == Nothing = False
    | otherwise = check_params b

member_func::[String]->[[String]]->Maybe String
member_func a [] = Nothing
member_func (nume:parametrii) ((numele:retu:params):restul)
    | nume==numele && parametrii == params = Just retu
    | otherwise = member_func (nume:parametrii) restul

find_func::Program->String->String->[String]->Maybe String
find_func prog clasa nume parametrii = if in_asta /= Nothing then in_asta
                                       else if daddy == [] then Nothing
                                            else find_func prog daddy nume parametrii 
    where functiile_clasei = getFuncsForClass clasa prog
          in_asta = member_func (nume:parametrii) functiile_clasei
          daddy = if clasa == "Global" then [] else getParentClass clasa prog

		  
infer :: Expr -> Program -> Maybe String
infer (Va s) p = gaseste s (getVars p)
infer (FCall s_var s_func exprs) p = if var_exists == False then Nothing
                                     else if param_ok == False then Nothing
                                          else find_func p (getFromMaybe clasa_din_care_apelez) s_func param_list
    where variabile = getVars p
          clasa_din_care_apelez = gaseste s_var variabile
          var_exists = if clasa_din_care_apelez == Nothing then False else True
          expresii = map ((flip infer) p) exprs
          param_ok = check_params expresii
          param_list = if param_ok==True then map getFromMaybe expresii else []