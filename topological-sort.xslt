<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:f="xslt:functions:2020"
  xmlns:g="xslt:graph-api:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  exclude-result-prefixes="xs f g map">

  <!--
    Returns vertices in topological sort order
    See https://en.wikipedia.org/wiki/Topological_sorting
      $g - a graph to traverse.      
      Returns a sequence of vertices.
  -->
  <xsl:function name="g:topological-sort" as="item()*">
    <xsl:param name="g" as="map(*)"/>
  
    <xsl:sequence select="reverse(g:topological-sort-reverse($g))"/>
  </xsl:function>
  
  <!--
    Returns vertices in topological sort reverse order
    See https://en.wikipedia.org/wiki/Topological_sorting
      $g - a graph to traverse.      
      Returns a sequence of vertices.
  -->
  <xsl:function name="g:topological-sort-reverse" as="item()*">
    <xsl:param name="g" as="map(*)"/>

    <xsl:sequence select="
      f:while
      (
        function($state as map(*)) { exists(head($state?vertices)) },
        function($state as map(*)) 
        {
          let $visited := $state?visited return
          let $vertex := head($state?vertices) return
            if ($visited($vertex)) then
              ()
            else
              reverse(g:search($vertex, $g, false(), $visited)?to)
        },
        function($state as map(*), $items as item()*)
        {
          map
          {
            'vertices': tail($state?vertices),
            'visited': map:merge(($state?visited, $items!map { .: true() }))
          }
        },
        map 
        {
          'vertices': g:vertices($g),
          'visited': map {}
        }
      )"/>
  </xsl:function>

</xsl:stylesheet>
