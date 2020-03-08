(*
  This file is part of the Lawspec compiler, a specification language for tax and social benefits
  computation rules.
  Copyright (C) 2019 Inria, contributor: Denis Merigoux <denis.merigoux@inria.fr>

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*)

%{
  open Ast
%}

%token EOF
%token<string> LAW_ARTICLE
%token<string> LAW_CODE
%token<string> LAW_TEXT
%token<string> CONSTRUCTOR IDENT
%token<string> END_CODE
%token<int> INT_LITERAL
%token BEGIN_CODE CHOICE
%token COLON ALT DOT SITUATION SOURCE DATA
%token OF SEMICOLON INTEGER TYPE COLLECTION
%token RULE CONDITION CONSEQUENCE DEFINED AS
%token EXISTS IN SUCH THAT NOW LESSER GREATER
%token BANG AND OR LPAREN RPAREN OPTIONAL EQUAL
%token COMMA CARDINAL LESSER_EQUAL GREATER_EQUAL

%type <Ast.source_file> source_file

%start source_file

%%

choice:
| CONSTRUCTOR {}

choices:
| ALT choice choices {}
| {}

type_ident:
| IDENT {}
| INTEGER {}

situation_type_alt:
| CHOICE IDENT {}
| TYPE type_ident {}
| SITUATION CONSTRUCTOR {}

situation_type:
| OF situation_type_alt {}
| {}

qident:
| IDENT {}
| CONSTRUCTOR {}
| IDENT BANG IDENT {}

primitive_expression:
| NOW {}

literal:
| INT_LITERAL {}

compare_op:
| LESSER {}
| LESSER_EQUAL {}
| GREATER {}
| GREATER_EQUAL {}
| EQUAL {}

func:
| CARDINAL {}

base_expression:
| primitive_expression {}
| literal {}
| func LPAREN separated_nonempty_list(COMMA, expression) RPAREN {}
| qident {}
| LPAREN expression RPAREN {}

sum_expression:
| base_expression {}

logical_op:
| AND {}
| OR {}

compare_expression:
| sum_expression {}
| sum_expression compare_op sum_expression {}

logical_expression:
| compare_expression {}
| compare_expression logical_op compare_expression {}

expression:
| EXISTS IDENT IN qident SUCH THAT expression {}
| logical_expression {}

condition:
| CONDITION expression CONSEQUENCE {}

rule_definition:
| AS expression {}
| {}

rule:
| option(condition) qident DEFINED rule_definition {}

situation:
| DATA IDENT option(COLLECTION) situation_type {}
| RULE option(OPTIONAL) rule {}

code_item:
| CHOICE IDENT COLON choices { }
| SITUATION CONSTRUCTOR SOURCE IDENT COLON separated_nonempty_list(SEMICOLON, situation) { }

code:
| code_item DOT code {}
| {}

source_file_item:
| title = LAW_ARTICLE { LawArticle title }
| code = LAW_CODE { LawCode code }
| text = LAW_TEXT { LawText text }
| BEGIN_CODE code text = END_CODE { CodeBlock text }

source_file:
| i = source_file_item f = source_file { i::f }
| EOF { [] }