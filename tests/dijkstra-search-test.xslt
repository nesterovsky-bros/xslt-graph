<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:g="xslt:graph-api:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  xmlns:t="public:this"
  exclude-result-prefixes="xs g map array t">

  <xsl:import href="../functions.xslt"/>
  <xsl:import href="../priority-queue.xslt"/>
  <xsl:import href="../graph.xslt"/>
  <xsl:import href="../search.xslt"/>
  <xsl:import href="../dijkstra-search.xslt"/>

  <xsl:template match="/">
    <xsl:variable name="g" as="map(*)" select="t:create-graph()"/>
    <xsl:variable name="source" as="xs:integer" select="1"/>
    <xsl:variable name="target" as="xs:integer" select="5"/>

    <xsl:message>
      <xsl:text>Shortest path:
</xsl:text>

      <xsl:for-each select="g:dijkstra-search($source, $target, $g)">
        <xsl:value-of separator="" select="
          ?from, ' - ', ?to, 
          ', distance = ', g:edge-value(?edge, $g),
          ', total = ', ?distance"/>

        <xsl:text>
</xsl:text>
      </xsl:for-each>
    </xsl:message>
  </xsl:template>

  <xsl:function name="t:create-graph" as="map(*)">
    <xsl:variable name="routes" as="map(*)*" select="
      map { 'from': 1, 'to': 2, 'value': 7 }, 
      map { 'from': 1, 'to': 3, 'value': 9 }, 
      map { 'from': 1, 'to': 6, 'value': 14 }, 
      map { 'from': 2, 'to': 3, 'value': 10 }, 
      map { 'from': 2, 'to': 4, 'value': 15 }, 
      map { 'from': 3, 'to': 4, 'value': 11 }, 
      map { 'from': 3, 'to': 6, 'value': 2 }, 
      map { 'from': 4, 'to': 5, 'value': 6 }, 
      map { 'from': 5, 'to': 6, 'value': 9 }"/>

    <xsl:variable name="vertices" as="map(*)" select="
      map:merge
      (
        $routes!(map { ?from : . }, map { ?to : . }),
        map { 'duplicates': 'combine' }
      )"/>

    <xsl:sequence select="
      map
      {
        'vertices': function() { map:keys($vertices) }, 
        'edges': function() { $routes }, 
        'edge-value': function($edge as map(*)) { $edge?value },
        'edge-vertices': function($edge as map(*)) { $edge?from, $edge?to },
        'vertex-edges': function($vertex as xs:integer) { $vertices($vertex) }
      }"/>
  </xsl:function>


</xsl:stylesheet>
