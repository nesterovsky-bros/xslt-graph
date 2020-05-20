<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:g="xslt:graph-api:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  exclude-result-prefixes="xs g map">

  <!--
    Returns vertices in topological sort order.
    See https://en.wikipedia.org/wiki/Topological_sorting
      $g - a graph to traverse.      
      Returns a sequence of vertices.
  -->
  <xsl:function name="g:topological-sort" as="item()*">
    <xsl:param name="g" as="map(*)"/>
  
    <xsl:sequence select="reverse(g:topological-sort-reverse($g))"/>
  </xsl:function>
  
  <!--
    Returns vertices in reverse topological sort order.
    See https://en.wikipedia.org/wiki/Topological_sorting
      $g - a graph to traverse.      
      Returns a sequence of vertices.
  -->
  <xsl:function name="g:topological-sort-reverse" as="item()*">
    <xsl:param name="g" as="map(*)"/>

    <xsl:iterate select="g:vertices($g)">
      <xsl:param name="visited" as="map(*)" select="map {}"/>

      <xsl:variable name="vertex" as="item()" select="."/>

      <xsl:if test="not($visited($vertex))">
        <xsl:variable name="items" as="item()*" 
          select="reverse(g:search($vertex, $g, false(), $visited)?to)"/>

        <xsl:next-iteration>
          <xsl:with-param name="visited" 
            select="map:merge(($visited, $items!map { .: true() }))"/>
        </xsl:next-iteration>
      </xsl:if>
    </xsl:iterate>
  </xsl:function>

</xsl:stylesheet>
