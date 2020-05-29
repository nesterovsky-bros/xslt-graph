<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:g="xslt:graph-api:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  xmlns:t="public:this"
  exclude-result-prefixes="xs g map array t">

  <xsl:import href="../priority-queue.xslt"/>
  <xsl:import href="../graph.xslt"/>
  <xsl:import href="../articulation-points.xslt"/>

  <xsl:template match="/">
    <xsl:variable name="g" as="map(*)" select="t:create-graph()"/>
    <xsl:message>
      <xsl:text>Articulation Points:
</xsl:text>

      <xsl:value-of select="g:articulation-points($g)"/>
    </xsl:message>
  </xsl:template>

  <xsl:function name="t:create-graph" as="map(*)">
    <xsl:variable name="routes" as="map(*)*" select="
      map { 'from': 1, 'to': 2 }, 
      map { 'from': 1, 'to': 3 }, 
      map { 'from': 2, 'to': 4 }, 
      map { 'from': 3, 'to': 4 }, 
      map { 'from': 4, 'to': 5 }, 
      map { 'from': 5, 'to': 6 }, 
      map { 'from': 6, 'to': 7 }, 
      map { 'from': 7, 'to': 8 }, 
      map { 'from': 7, 'to': 15 }, 
      map { 'from': 8, 'to': 9 }, 
      map { 'from': 8, 'to': 10 }, 
      map { 'from': 10, 'to': 11 }, 
      map { 'from': 10, 'to': 12 }, 
      map { 'from': 12, 'to': 13 }, 
      map { 'from': 13, 'to': 14 }, 
      map { 'from': 13, 'to': 15 }, 
      map { 'from': 14, 'to': 15 }"/>

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
        'edge-vertices': function($edge as map(*)) { $edge?from, $edge?to },
        'vertex-edges': function($vertex as xs:integer) { $vertices($vertex) }
      }"/>
  </xsl:function>

</xsl:stylesheet>
