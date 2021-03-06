/**
 *
 * Copyright (C) 2011, NUI Galway.
 * Copyright (C) 2014, NUI Galway, WU Wien, Politecnico di Milano, Vienna University of Technology 
 * All rights reserved.
 *
 * The software in this package is published under the terms of the BSD style license a copy of which has been included
 * with this distribution in the bsb_license.txt file and/or available on NUI Galway Server at
 * http://xsparql.deri.ie/license/bsd_license.txt
 *
 * Created on 09 February 2011 by Reasoning and Querying Unit (URQ), Digital Enterprise Research Institute (DERI) on behalf of
 * NUI Galway.
 * 20 May 2014 by Axel Polleres on behalf of WU Wien, Daniele Dell'Aglio on behalf of Politecnico di Milano,  Stefan 
 * Bischof on behalf of Vienna University of Technology,  Nuno Lopes on behalf of NUI Galway.
 * 
 */
 
tree grammar XQuerySerializer;

options {
  tokenVocab=XSPARQLRewriter;
  ASTLabelType=CommonTree;
  output=template;
}

tokens {

  REWRITEVNODE;
  REWRITEVNODE1;
  DELETEVNODE;
  COMMENT;
  T_QSTRING;
  
  NOTHING;

  // Lexer tokens
  VAR;ENDELM;INTEGER;LCURLY;RCURLY;NCNAME;QSTRING;DOT;AT;ASSIGN;CARET;CARETCARET;COLON;COMMA;SLASH;
  LBRACKET;RBRACKET;LPAR;RPAR;SEMICOLON;STAR;DOTDOT;SLASHSLASH;LESSTHAN;GREATERTHAN; PLUS;MINUS;
  UNIONSYMBOL;QUESTIONMARK;LESSTHANLESSTHAN;GREATERTHANEQUALS;LESSTHANEQUALS;HAFENEQUALS;EQUALS;
  COLONCOLON;  BLANK_NODE_LABEL;BNODE_CONSTRUCT;IRI_CONSTRUCT;ASK;DESCRIBE;SELECT;PNAME_NS;PNAME_LN;
  CDATASTART;CDATAELMEND;RCURLYGREATERTHAN;LESSTHANLCURLY;ORSYMBOL;ANDSYMBOL;NOT;WHITESPACE;IRIREF;
  NCNAMEELM;ENDTAG;A;IS;EQ;NE;LT;GE;LE;GT;FOR;FROM;LIMIT;OFFSET;LET;ORDER;BY;ATS;IN;AS;DESCENDING;
  ASCENDING;STABLE;IF;THEN;ELSE;RETURN;CONSTRUCT;WHERE;GREATEST;LEAST;COLLATION;CHILD;DESCENDANT;
  ATTRIBUTE;SELF;DESCENDANTORSELF;FOLLOWINGSIBLING;FOLLOWING;PARENT;ANCESTOR;PRECEDINGSIBLING;PRECEDING;
  ANCESTORORSELF;ORDERED;UNORDERED;DECLARE;NAMESPACE;DEFAULT;ELEMENT;FUNCTION;BASEURI;PREFIX;BASE;AND;OR;
  TO;DIV;IDIV;MOD;UNION;INTERSECT;EXCEPT;INSTANCE;TREAT;CASTABLE;CAST;OF;EMPTYSEQUENCE;ITEM;NODE;DOCUMENTNODE;
  TEXT;COMMENT;PROCESSINGINSTRUCTION;SCHEMAATTRIBUTE;SCHEMAELEMENT;DOCUMENT;NAMED;OPTIONAL;FILTER;STR;LANG;
  LANGMATCHES;DATATYPE;BOUND;ISIRI;ISURI;ISBLANK;ISLITERAL;REGEX;TRUE;FALSE;GRAPH;GREATERTHANGREATERTHAN;
  DISTINCT;GROUP;HAVING;

  // AST tokens
  T_NAMESPACE;
  T_XML_ELEMENT;
  T_XML_CONTENT;
  T_XML_CONTENTS;
  T_XML_ATTRIBUTE;
  T_FLWOR;
  T_FUNCTION_DECL;
  T_PARAMS;
  T_FORLET;
  T_WHERE;
  T_SPARQL_FOR;
  T_SPARQL_WHERE;
  T_FOR;
  T_LET;
  T_CONSTRUCT;
  T_ORDER;
  T_RETURN;
  T_UNION;

  T_BLANK;
  T_ANON_BLANK;
  T_EMPTY_ANON_BLANK;

  T_SUBJECT;
  T_VERB;
  T_OBJECT;
  T_MAIN;
  T_PAR;

  T_INSTANCEOF;
  T_TYPE;
  T_CASTAS;
  T_CASTABLEAS;
  T_TREATAS;

  T_VARIABLE_DECL;
  T_EXTERNAL_VARIABLE_DECL;
  T_OPTION_DECL;
  T_FUNCTION_CALL;
  T_PARAM;

  T_ORDER_BY;
  T_STABLE_ORDER_BY;

  T_GROUP_BY;
  T_HAVING;
  
  T_ASVAR;

  // XQuery keywords
  BOUNDARYSPACE;
  STRIP;
  VARIABLE;
  IMPORT;
  EXTERNAL;
  NOPRESERVE;
  PRESERVE;
  CONSTRUCTION;
  MODULE;
  INHERIT;
  NOINHERIT;
  SCHEMA;
  EMPTY;
  ORDERING;
  COPYNAMESPACES;
  XQUERY;
  VERSION;
  ENCODING;
  OPTION;
  LAX;
  CASE;
  EVERY;
  TYPESWITCH;
  SATISFIES;
  VALIDATE;
  SOME;
  STRICT;

  // SPARQL keywords
  ASC;
  DESC;
  
  // SPARQL 1.1
  BIND;

  T_MODULE_DECL;
  T_VERSION;
  T_BOUNDARYSPACE_DECL;
  T_DEFAULT_DECL;
  T_ORDER_DECL;
  T_EMPTY_ORDER_DECL;
  T_DEFAULT_COLLATION_DECL;
  T_BASEURI_DECL;
  T_MODULE_IMPORT;
  T_SCHEMA_IMPORT;

  T_QUERY_BODY;
  T_BODY_PART;

  XPATH;

  T_LITERAL_CONSTRUCT;
  T_IRI_CONSTRUCT;

  T_EPILOGUE;
  
  T_SQL_FOR;
  T_SQL_FROM;
  T_TABLE;
  T_VAR;
  ENDPOINT;
  DECIMAL;
  ROW;
  T_UNOPTIMIZED_FUNCTION_CALL;
  ADDSYMBOL;
}

@header {
  package org.sourceforge.xsparql.rewriter;
}

// start rule MUST NOT be recursive in ANTLR
root : a=main -> generic(content={$a.st})
  ;

main
  :  ^(T_MAIN mains+=main+)
    -> main(date={new java.util.Date().toString()}, queryBodies={$mains})
  | ^(T_QUERY_BODY mains1+=main+)
    -> queryBody(main={$mains1})
  | ^(T_BODY_PART mains2+=main+)
    -> generic(content={$mains2})
  |  ^(T_NAMESPACE d=main e=main)
    -> namespace(name={$d.st}, value={$e.st})
  |  ^(T_NAMESPACE DEFAULT e=main)
    -> defaultnamespace(value={$e.st})
  |  ^(T_NAMESPACE BASE e=main)
    -> defaultnamespace(value={$e.st})
  |  ^(T_DEFAULT_DECL dd1=main dd2=main dd3=main)
    -> defaultDecl(dd1={$dd1.st}, dd2={$dd2.st}, dd3={$dd3.st})
  |  ^(T_OPTION_DECL dd1=main dd2=main)
    -> optionDecl(dd1={$dd1.st}, dd2={$dd2.st})
  |  ^(FROM f=main)
    -> template(a={$f.text}) "from $a$"
  |  ^(T_FLWOR flcs+=main+)
    -> flworExpr(forlets={$flcs})
  |  ^(T_WHERE where=main)
    -> whereExpr(main={$where.st})
  |  WHERE where=main
    -> sqlWhereExpr(main={$where.st})
  |  ^(FILTER filter+=main*)
    -> filterExpr(main={$filter})
	|  ^(BIND bind+=main*)
	  -> bindExpr(main={$bind})
  |  ^(T_ASVAR asvar+=main*)
    -> generic(content={$asvar})
  |  ^(T_ORDER order=main)
    -> generic(content={$order.st})
  |  ^(T_ORDER_BY order1=main spec=main?)
    -> orderExpr(main={$order1.st}, ordering={$spec.text})
  |  ^(T_ORDER_DECL order1=main)
    -> orderDecl(main={$order1.st})
  |  ^(T_RETURN ret+=main+)
    -> returnExpr(main={$ret})
  |  comment=COMMENT
    -> comment(comment={$comment})
  |  DELETEVNODE   // should not be needed here
    -> 
  |  ^(T_XML_ELEMENT name=main attributes+=xmlAttribute* contents+=main*)
    -> xmlElement(name={$name.st}, attributes={$attributes}, contents={$contents})
  |  ^(T_XML_CONTENT ^(T_XML_CONTENTS c1+=main+))
    -> xmlContents(content={$c1})
  |  ^(T_XML_CONTENT c1+=main+)
    -> xmlContent(content={$c1})
  |  ^(T_VARIABLE_DECL v1=main ^(T_TYPE v2=main?) v3=main?)
    -> varDecl(v1={$v1.st}, v2={$v2.st}, v3={$v3.st})
  |  ^(T_EXTERNAL_VARIABLE_DECL v1=main ^(T_TYPE v2=main?))
    -> externalVarDecl(v1={$v1.st}, v2={$v2.st})
  |  ^(T_PAR e2+=main*)
    -> par(content={$e2})
  |  ^(T_MODULE_IMPORT (^(NAMESPACE mi1=main?))? mi2=main ^(AT mi3=main*))
    -> moduleImport(mi1={$mi1.st}, mi2={$mi2.st}, mi3={$mi3.st})
  |  ^(T_SCHEMA_IMPORT ^(NAMESPACE mi1=main?) mi2=main ^(AT mi3=main*))
    -> schemaImport(mi1={$mi1.st}, mi2={$mi2.st}, mi3={$mi3.st})
  |  ^(T_FUNCTION_DECL fname1=main ^(T_PARAMS params+=main*) (^(AS as=main (op=QUESTIONMARK|op=STAR|op=PLUS)?))? definition=main?)
    -> funcDecl(name={$fname1.st}, params={$params}, as={$as.st}, op={$op.text}, definition={$definition.st})
  |  ^(T_PARAM param=main ^(T_TYPE type=main? (pars=(LPAR RPAR))? (op=QUESTIONMARK|op=STAR|op=PLUS)?))
    -> param(name={$param.st}, type={$type.st}, pars={$pars.text}, op={$op.text})
  |  ^(T_FUNCTION_CALL fname=main ^(T_PARAMS fexpr+=main*))
    -> funcCall(name={$fname.st}, expr={$fexpr})
  |  ^(T_UNOPTIMIZED_FUNCTION_CALL fname=main ^(T_PARAMS fexpr+=main*))
    -> funcCall(name={$fname.st}, expr={$fexpr})
  |  ^(T_FOR a=VAR (^(T_TYPE t=main))? ^(AT c=VAR) ^(IN e3+=main+))
    -> forClause(var={$a.text}, type={$t.st}, at={$c.text}, in={$e3})
  | ^((op=EVERY|op=SOME) vars+=main+ ^(SATISFIES er=main))   // TODO: only outputting 
    -> quantifiedExpr(op={$op},vars={$vars}, satisfies={$er.st})
  | ^(T_VAR v=VAR (^(T_TYPE tm=main))? ^(IN m=main)) 
    -> var(var={$v.text}, type={$tm.st}, in={$m.st})
  |  ^(T_LET b=main (d1+=main)+)
    -> letClause(var={$b.st}, expr={$d1})
  |  ^(T_INSTANCEOF test=main type=main)
    -> instanceOf(test={$test.st}, type={$type.st})
  |  ^(XPATH xp+=main+)
    -> generic(content={$xp})
  |  ^(TO from=main to=main)
    -> rangeExpr(from={$from.st}, to={$to.st})
  |  ^((op=LESSTHAN|op=PLUS|op=MINUS|op=STAR|op=DIV|op=IDIV|op=MOD) (p1=main p2=main)?)
    -> infixOpExpr(p1={$p1.st}, p2={$p2.st}, op={$op})
  |  x=XPATH
    -> generic(content={$x.text})
  |  ^(IF cond=main then=main elseExpr=main)
    -> ifExpr(cond={$cond.st}, then={$then.st}, elseExpr={$elseExpr.st})
  |  ^(OR or1=main or2=main)
    -> infixOpExpr(p1={$or1.st}, p2={$or2.st}, op={$OR.text})
  |  ^(AND or1=main or2=main)
    -> infixOpExpr(p1={$or1.st}, p2={$or2.st}, op={$AND.text})
  |  ^(EXCEPT or1=main or2=main)
    -> infixOpExpr(p1={$or1.st}, p2={$or2.st}, op={$EXCEPT.text})
  |  ^(T_OBJECT a5=main)
    -> objectClause(object={$a5.st})
  |  ^(T_TYPE type=main?)
    -> generic(content={$type.st})
  |  ^((op=LT|op=GT|op=LE|op=GE|op=EQUALS|op=GREATERTHAN|op=EQ|op=NE|op=HAFENEQUALS) eq1=main eq2=main)
    -> infixOpExpr(p1={$eq1.st}, p2={$eq2.st}, op={$op})
  |  q=QSTRING
    -> qstring(qs={$q.text})
  |  ^(T_QSTRING strparts+=main+)
    -> qstring(qs={$strparts})
  |  ^(T_GROUP_BY gc+=main+)
    -> group_by(groupcondition={$gc})
  |  ^(T_HAVING expr+=main+)
    -> having(expr={$expr})
  |  INTEGER
    -> {%{$INTEGER.text}}
  |  DECIMAL
    -> {%{$DECIMAL.text}}
  |  var=VAR
	  -> generic(content={$var.text})
  |  LPAR
    -> {%{$LPAR.text}}
  |  RPAR
    -> {%{$RPAR.text}}
  |  LCURLY
    -> {%{$LCURLY.text}}
  |  RCURLY
    -> {%{$RCURLY.text}}
  |  LBRACKET
    -> {%{$LBRACKET.text}}
  |  RBRACKET
    -> {%{$RBRACKET.text}}
  |  CARET
    -> {%{$CARET.text}}
  |  ORDERED
    -> {%{$ORDERED.text}}
  |  UNORDERED
    -> {%{$UNORDERED.text}}
  |  UNIONSYMBOL
    -> {%{$UNIONSYMBOL.text}}
  |  ADDSYMBOL
    -> {%{$ADDSYMBOL.text}}
  |  ANDSYMBOL
    -> {%{$ANDSYMBOL.text}}
  |  ORSYMBOL
    -> {%{$ORSYMBOL.text}}
  |  ncname=NCNAME
    -> generic(content={$ncname.text})
  |  IRIREF
    -> {%{$IRIREF.text}}
  |  PNAME_LN
    -> {%{$PNAME_LN.text}}
  |  PNAME_NS
    -> {%{$PNAME_NS.text}}
  |  NCNAMEELM
    -> {%{$NCNAMEELM.text}}
  |  WHITESPACE
    -> {%{$WHITESPACE.text}}
  |  A
    -> {%{$A.text}}
  |  SLASH
    -> {%{$SLASH.text}}
  |  AT
    -> {%{$AT.text}}
  |  NOT
    -> {%{$NOT.text}}
  |  ISBLANK
    -> {%{$ISBLANK.text}}
  |  ISIRI
    -> {%{$ISIRI.text}}
  |  (ITEM LPAR RPAR)
    -> emptyItem(item={$ITEM.text})
  |  ITEM
    -> {%{$ITEM.text}}
  |  LANG
    -> {%{$LANG.text}}
  |  LANGMATCHES
    -> {%{$LANGMATCHES.text}}
  |  COLON
    -> {%{$COLON.text}}
  |  COLONCOLON
    -> {%{$COLONCOLON.text}}
  |  (ELEMENT LPAR RPAR)
    -> emptyItem(item={$ELEMENT.text})
  |  ELEMENT
    -> {%{$ELEMENT.text}}
  |  (NODE LPAR RPAR)
    -> emptyItem(item={$NODE.text})
  |  NODE
    -> {%{$NODE.text}}
  |  (DOCUMENTNODE LPAR RPAR)
    -> emptyItem(item={$DOCUMENTNODE.text})
  |  DOCUMENTNODE
    -> {%{$DOCUMENTNODE.text}}
  |  (DOCUMENT LPAR RPAR)
    -> emptyItem(item={$DOCUMENT.text})
  |  DOCUMENT
    -> {%{$DOCUMENT.text}}
  |  (TEXT LPAR RPAR)
    -> emptyItem(item={$TEXT.text})
  |  TEXT
    -> {%{$TEXT.text}}
  |  DOT
    -> {%{$DOT.text}}
  |  DOTDOT
    -> {%{$DOTDOT.text}}
  |  NAMESPACE
    -> {%{$NAMESPACE.text}}
  |  CDATASTART
    -> {%{$CDATASTART.text}}
  |  cd=CDATAELMEND
    -> generic(content={$cd.text})
  | CHILD 
    -> {%{$CHILD.text}}
  | DESCENDANT 
    -> {%{$DESCENDANT.text}}
  | ATTRIBUTE 
    -> {%{$ATTRIBUTE.text}}
  | SELF 
    -> {%{$SELF.text}}
  | DESCENDANTORSELF 
    -> {%{$DESCENDANTORSELF.text}}
  | FOLLOWINGSIBLING 
    -> {%{$FOLLOWINGSIBLING.text}}
  | FOLLOWING 
    -> {%{$FOLLOWING.text}}
  | PARENT 
    -> {%{$PARENT.text}}
  | ANCESTOR 
    -> {%{$ANCESTOR.text}}
  | PRECEDINGSIBLING 
    -> {%{$PRECEDINGSIBLING.text}}
  | PRECEDING 
    -> {%{$PRECEDING.text}}
  | ANCESTORORSELF 
    -> {%{$ANCESTORORSELF.text}}
  | BOUNDARYSPACE 
    -> {%{$BOUNDARYSPACE.text}}
  | STRIP 
    -> {%{$STRIP.text}}
  | VARIABLE 
    -> {%{$VARIABLE.text}}
  | IMPORT 
    -> {%{$IMPORT.text}}
  | EXTERNAL 
    -> {%{$EXTERNAL.text}}
  | NOPRESERVE 
    -> {%{$NOPRESERVE.text}}
  | PRESERVE 
    -> {%{$PRESERVE.text}}
  | CONSTRUCTION 
    -> {%{$CONSTRUCTION.text}}
  | MODULE 
    -> {%{$MODULE.text}}
  | INHERIT 
    -> {%{$INHERIT.text}}
  | NOINHERIT 
    -> {%{$NOINHERIT.text}}
  | SCHEMA 
    -> {%{$SCHEMA.text}}
  | EMPTY 
    -> {%{$EMPTY.text}}
  | ORDERING 
    -> {%{$ORDERING.text}}
  | ASCENDING
    -> {%{$ASCENDING.text}}
  | DESCENDING 
    -> {%{$DESCENDING.text}}
  | COPYNAMESPACES 
    -> {%{$COPYNAMESPACES.text}}
  | XQUERY 
    -> {%{$XQUERY.text}}
  | VERSION 
    -> {%{$VERSION.text}}
  | ENCODING 
    -> {%{$ENCODING.text}}
  | LAX 
    -> {%{$LAX.text}}
  | CASE 
    -> {%{$CASE.text}}
  | TYPESWITCH 
    -> {%{$TYPESWITCH.text}}
  | SATISFIES 
    -> {%{$SATISFIES.text}}
  | IN
    -> {%{$IN.text}}
  | VALIDATE 
    -> {%{$VALIDATE.text}}
  | SOME 
    -> {%{$SOME.text}}
  | STRICT 
    -> {%{$STRICT.text}}
  ;

xmlAttribute
  : ^(T_XML_ATTRIBUTE name=NCNAME value=QSTRING)
  -> xmlAttribute(name={$name}, value={$value})
  | ^(T_XML_ATTRIBUTE name=PNAME_LN value=QSTRING)
  -> xmlAttribute(name={$name}, value={$value})
  ;

