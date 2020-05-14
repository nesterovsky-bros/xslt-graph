<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:g="xslt:graph-api:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  exclude-result-prefixes="xs g map">

  <!--
    Returns vertices in topological sort order
    See https://en.wikipedia.org/wiki/Topological_sorting
      $g - a graph to traverse.      
      Returns a sequence of vertices.
  -->
  <xsl:function name="g:topological-sort" as="item()*">
    <xsl:param name="g" as="map(*)"/>

    <xsl:sequence select="g:topological-sort(g:vertices($g), $g, map {}, ())"/>
  </xsl:function>

  <!--
    Returns vertices in topological sort order.
    See https://en.wikipedia.org/wiki/Topological_sorting
      $vertices - a sequence of vertices to process.
      $g - a graph to traverse.      
      $visited - a set of visited vertices.
      $result - collected result.
      Returns a sequence of vertices.
  -->
  <xsl:function name="g:topological-sort" as="item()*">
    <xsl:param name="vertices" as="item()*"/>
    <xsl:param name="g" as="map(*)"/>
    <xsl:param name="visited" as="map(*)"/>
    <xsl:param name="result" as="item()*"/>

    <xsl:variable name="vertex" as="item()?" select="head($vertices)"/>

    <xsl:choose>
      <xsl:when test="empty($vertex)">
        <xsl:sequence select="$result"/>
      </xsl:when>
      <xsl:when test="$visited($vertex)">
        <xsl:sequence 
          select="g:topological-sort(tail($vertices), $g, $visited, $result)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="search-result" as="map(*)" select="
          g:search
          (
            [map { 'to': $vertex, 'depth': 0 }], 
            $g,
            false(),
            function($item as map(*), $visited as map(*), $state as map(*)*) 
              as map(*)*
            {
              map
              {
                'visited': $visited,
                'result': ($state?result, $item)
              }
            },
            map
            {
              'visited': $visited,
              'result': ()
            },
            $visited
          )"/>

        <xsl:sequence select="
          g:topological-sort
          (
            tail($vertices), 
            $g, 
            $search-result?visited, 
            ($search-result?result?to, $result)
          )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
