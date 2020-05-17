<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:g="xslt:graph-api:2020"
  xmlns:f="xslt:functions:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  exclude-result-prefixes="xs g f map array">

  <!--
    Traverses graph starting from the root vertex.
    See https://en.wikipedia.org/wiki/Depth-first_search and
      https://en.wikipedia.org/wiki/Breadth-first_search.

      $root - a root vertex.
      $g - a graph to traverse.
      $is-depth-first - true() for depth first, and 
        false() for breadth first search.
      $visited - a set of visited vertices.
      Returns last state.
  -->
  <xsl:function name="g:search" as="map(*)*">
    <xsl:param name="root" as="item()"/>
    <xsl:param name="g" as="map(*)"/>
    <xsl:param name="is-depth-first" as="xs:boolean"/>
    <xsl:param name="visited" as="map(*)"/>

    <xsl:sequence select="
      f:while
      (
        function($state as map(*)) { array:size($state?queue) > 0 },
        function($state as map(*))
        {
          array:head($state?queue)[not($state?visited(?to))] 
        },
        function($state as map(*), $item as item()*) 
        {
          let $tail := array:tail($state?queue) return
            if (empty($item)) then
              map { 'queue': $tail, 'visited': $state?visited }
            else
              let $to := $item?to return
              let $visited := map:put($state?visited, $to, true()) return
              let 
                $items :=
                  array 
                  {
                    for 
                      $edge in g:vertex-edges($to, $g),
                      $vertex in g:edge-vertices($edge, $g)
                    return
                      if ($visited($vertex)) then
                        ()
                      else
                        map 
                        { 
                          'from': $to, 
                          'to': $vertex, 
                          'edge': $edge,
                          'depth': $item?depth + 1
                        }
                  }
                return
                  map
                  {
                    'queue':
                      if ($is-depth-first) then
                        array:join(($items, $tail))
                      else
                        array:join(($tail, $items)),
                    'visited': $visited
                  }
        },
        map 
        { 
          'queue': [ map { 'to': $root, 'depth': 0 } ],
          'visited': $visited
        }
      )"/>
  </xsl:function>

</xsl:stylesheet>