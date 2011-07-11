(:


    Copyright (C) 2011, NUI Galway.
    All rights reserved.

    The software in this package is published under the terms of the BSD style license a copy of which has been included
    with this distribution in the bsb_license.txt file and/or available on NUI Galway Server at
    http://www.deri.ie/publications/tools/bsd_license.txt

    Created: 09 February 2011, Reasoning and Querying Unit (URQ), Digital Enterprise Research Institute (DERI) on behalf of
    NUI Galway.

:)

module namespace _xsparql =  "http://xsparql.deri.org/demo/xquery/xsparql.xquery" ;


(: import schema namespace _sparql_result =  "http://www.w3.org/2005/sparql-results#" at "http://www.w3.org/2005/sparql-results#result.xsd"; :)
import schema namespace _sparql_result =  "http://www.w3.org/2005/sparql-results#" at "sparql.xsd";


(: Determine if valid Blank node, uri or literal respectively, by checking if
   the parameter is an instance of the required type :)

declare function _xsparql:_validBNode($NType as item()*) as xs:boolean
{
  $NType instance of schema-element(_sparql_result:bnode)
};


declare function _xsparql:_validUri($NType as item()*) as xs:boolean
{
  $NType instance of schema-element(_sparql_result:uri)
};


declare function _xsparql:_validLiteral($NType as item()*) as xs:boolean
{
  if ($NType instance of schema-element(_sparql_result:literal))
    then fn:true()
  else fn:false()
};


(: check if the parameter is, respectively, a valid subject, predicate or object :)
declare function _xsparql:_validSubject($NType as item()*) as xs:boolean
{ 
  if (_xsparql:_validBNode($NType) or _xsparql:_validUri($NType) ) 
    then fn:true() 
  else fn:false()
};


declare function _xsparql:_validPredicate($NType as item()*) as xs:boolean
{ 
  _xsparql:_validUri($NType) or fn:matches(data($NType), "^a$") 
};


declare function _xsparql:_validObject($NType as item()*) as xs:boolean
{ 
  _xsparql:_validBNode($NType) or 
  _xsparql:_validUri($NType) or 
  _xsparql:_validLiteral($NType)
}; 


(: ------------------------------------------------------------------------------- :)
(: serialisation of an XML element maintaining the XML structrure :)
declare function _xsparql:_serialize-attributes (  $n as item()*  ) as xs:string 
{
  if(fn:empty($n)) 
    then ""
  else fn:concat(" ", 
                 fn:node-name($n[1]), "=""", fn:data($n[1]), """", 
                 _xsparql:_serialize-attributes( fn:subsequence( $n, 2 ) ) 
          ) 
};


declare function _xsparql:_serialize (  $n as item()* ) as xs:string {
  let $r :=
  for $item in $n
  return typeswitch ($item)
    case $Node as schema-element(_sparql_result:uri)
      return _xsparql:_rdf_term($Node)
    case $Node as schema-element(_sparql_result:bnode)
      return _xsparql:_rdf_term($Node)
    case $Node as schema-element(_sparql_result:literal)
      return _xsparql:_rdf_term($Node)
    case $e as element()
      return fn:concat("<", fn:name($e), _xsparql:_serialize-attributes($e/@*), ">",
                        _xsparql:_serialize($e/child::node()),
                        "</", fn:name($e), ">"
                      )
    default
      return fn:string($item)

    return fn:string-join($r,'')
};



(: ------------------------------------------------------------------------------- :)
(: returns the RDF representation of the $Node, according to it's type :)
declare function _xsparql:_rdf_term($Node as item()) as xs:string
{
  if ($Node instance of xs:anyAtomicType) 
    then $Node 
  else
    typeswitch($Node) 
      case $e as schema-element(_sparql_result:bnode)
        return fn:concat("_:", data($e), "")
      case $e as schema-element(_sparql_result:uri)
        return fn:concat("<", data($e), ">")
      case $e as schema-element(_sparql_result:literal)
        return
          let $DT := data($e/@datatype)
          let $L := data($e/@xml:lang) 
          let $value := if(data($e) instance of xs:integer and fn:empty($DT)) 
                          then data($e) 
                        else fn:concat("""", data($e), """")
            return fn:concat($value, if($L) then fn:concat("@", $L) else "", 
                                     if($DT) then fn:concat("^^<", $DT,">") else () 
                             )
       default 
         return ""
};


(: returns an element of a SPARQL type.  Used for conversion of XML elements when outputing RDF. 
   Determines the RDF type according to the XML type :)
declare function _xsparql:_binding_term($prefix as xs:string,
                                        $Node as xs:anyAtomicType, 
                                        $lang as xs:string, 
                                        $type as xs:string) as item()
{
  let $label := fn:concat($prefix, data($Node))
  return
  typeswitch ($Node)
    case $e as xs:integer
    return _xsparql:_binding("_sparql_result:literal",  $label, $lang, $type)
    case $e as xs:anyURI
    return _xsparql:_binding("_sparql_result:uri",  $label, "", "")
    default
    return if (fn:matches($label, "^_:[a-z]([a-z|0-9|_])*$", "i"))
      then _xsparql:_binding("_sparql_result:bnode",  fn:substring($label,3), "", "")
      else if (fn:matches($Node, "^([a-zA-Z]*):(.+)$")) 
        then _xsparql:_binding("_sparql_result:uri",  $label, "", "")
        else _xsparql:_binding("_sparql_result:literal",  $label, $lang, $type)
};



declare function _xsparql:_binding_term($Node as xs:anyAtomicType) as item()
{
  _xsparql:_binding_term("", $Node, "", "")
};

(: Creates an element of RDF type :)
declare function _xsparql:_binding($node as xs:string, 
                                   $value as xs:anyAtomicType, 
                                   $lang as xs:string,
                                   $type as xs:string) as item() 
{
  let $langAtt := if (string-length($lang) > 0) then attribute xml:lang { $lang } else ()
  let $typeAtt := if (string-length($type) > 0) then attribute datatype { $type } else ()
  return 
(:  validate {:) 
      element {$node} { 
      $langAtt,
      $typeAtt,
      $value 
      }
(:  }:)
};

(: Converts an RDF type element to XML.  To be used in a return clause :)
declare function _xsparql:_xml_term($Node as item()*) as item()*
{
  typeswitch ($Node)
    case schema-element(_sparql_result:uri)
    return fn:data($Node)
    case schema-element(_sparql_result:bnode)
    return fn:data($Node)
    case schema-element(_sparql_result:literal)
    return fn:data($Node)
    default
    return $Node
};



(: ------------------------------------------------------------------------------- :)
(: retrieves the value of variable $var from the SPARQL XML results format :)
declare function _xsparql:_resultNode($xml as item(), $var as xs:string) {
  let $node := $xml/_sparql_result:binding[@name = $var]/*
  return $node
};


(: returns the sequence of results from the SPARQL XML results format :)
declare function _xsparql:_sparqlResults ( $uri as xs:string )  {
(:    let $doc := ( validate { doc($uri) } )//schema-element(_sparql_result:sparql):)
    let $doc := doc($uri)//schema-element(_sparql_result:sparql)
    return $doc/_sparql_result:results/_sparql_result:result
};



(: These functions retrieve, from the specified endpoint the SPARQL XML results
file corresponding to the query :)
declare function _xsparql:_sparql ( $endpoint as xs:string, $query as item()* )  {
  _xsparql:_serialize(
    ($endpoint, fn:encode-for-uri(_xsparql:_serialize(($query))))
            )
};

declare function _xsparql:_sparql ( $query as item()* )  {
    _xsparql:_sparql ("http://localhost:2020/sparql?query=", $query)
};


declare function _xsparql:_insertData ( $prefix as xs:string, $data as xs:string)  {
  let $res := doc(fn:concat("http://localhost:2020/tdb/service?request=", 
                            fn:encode-for-uri(fn:concat($prefix,
                                                        "INSERT DATA {", $data,"}")))) 
  return data($res//boolean)
};


declare function _xsparql:_createRequest ( $graph as xs:string, $prefix as xs:string, $data as xs:string)  {
  fn:concat("PREFIX ex: <",$graph,">",$prefix,
            "CREATE SILENT GRAPH <",$graph,">",
            "INSERT DATA INTO <",$graph,"> {", $data,"}")
};


declare function _xsparql:_createNamedGraph ( $endpoint as xs:string, $graph as xs:string, $prefix as xs:string, $data as xs:string)  {
  let $res := doc(fn:concat($endpoint, fn:trace(_xsparql:_createRequest($graph, $prefix, $data), "request"))) 
  return data($res//boolean)
};

declare function _xsparql:_createNamedGraph($graph as xs:string, $prefix as xs:string, $data as xs:string) {
  _xsparql:_createNamedGraph("http://localhost:2020/tdb/service?request=", $graph,$prefix,fn:encode-for-uri($data))
};


declare function _xsparql:_dropRequest ( $graph as xs:string )  {
  fn:concat("DROP SILENT GRAPH <",$graph,">")
};

declare function _xsparql:_dropNamedGraph ( $endpoint as xs:string, $graph as xs:string )  {
  let $res := doc(fn:concat($endpoint, 
                            fn:encode-for-uri(fn:concat("DROP SILENT GRAPH <",$graph,">"))))
  return data($res//boolean)
};


declare function _xsparql:_dropNamedGraph ( $graph as xs:string )  {
  _xsparql:_dropNamedGraph("http://localhost:2020/tdb/service?request=", $graph)
};
