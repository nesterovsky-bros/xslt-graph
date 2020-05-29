<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:g="xslt:graph-api:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  xmlns:t="public:this"
  exclude-result-prefixes="xs g map array t">

  <xsl:import href="../graph.xslt"/>
  <xsl:import href="../connected-components.xslt"/>

  <xsl:template match="/">
    <xsl:variable name="g" as="map(*)" select="t:create-graph()"/>

    <xsl:variable name="components" as="map(*)*" select="g:connected-components($g)"/>
    
    <xsl:message>
      <xsl:text>Connected components:
</xsl:text>

      <xsl:for-each select="$components">
        <xsl:text>Component </xsl:text>
        <xsl:value-of select="?index"/>
        <xsl:text>:
   </xsl:text>
        <xsl:value-of select="sort(?vertices)"/>
        <xsl:text>
</xsl:text>
      </xsl:for-each>
    </xsl:message>
  </xsl:template>

  <xsl:function name="t:create-graph" as="map(*)">
    <xsl:variable name="routes" as="map(*)*" select="
      map { 'from': 1, 'to': 2 }, 
      map { 'from': 2, 'to': 4 }, 
      map { 'from': 4, 'to': 3 }, 
      map { 'from': 3, 'to': 1 },
                  
      map { 'from': 5, 'to': 6 }, 
      map { 'from': 6, 'to': 7 }, 
      map { 'from': 7, 'to': 9 }, 
      map { 'from': 9, 'to': 8 }, 
      map { 'from': 9, 'to': 10 }, 
      map { 'from': 10, 'to': 11 }, 
      map { 'from': 10, 'to': 12 }, 
      map { 'from': 12, 'to': 13 }, 
      map { 'from': 13, 'to': 14 }, 
      map { 'from': 14, 'to': 16 }, 
      map { 'from': 16, 'to': 17 }, 
      map { 'from': 17, 'to': 6 }, 
      map { 'from': 6, 'to': 15 }, 
      map { 'from': 6, 'to': 18 }, 
      map { 'from': 18, 'to': 19 }, 
      map { 'from': 19, 'to': 20 }, 
      map { 'from': 19, 'to': 21 }, 
      map { 'from': 21, 'to': 22 }, 
      map { 'from': 21, 'to': 23 }, 
      map { 'from': 13, 'to': 24 }, 
      map { 'from': 24, 'to': 25 }, 
      map { 'from': 24, 'to': 25 }, 
      map { 'from': 24, 'to': 26 }, 
                  
      map { 'from': 27, 'to': 28 }, 
      map { 'from': 28, 'to': 29 }, 
      map { 'from': 29, 'to': 30 }, 
      map { 'from': 30, 'to': 31 }, 
      map { 'from': 30, 'to': 32 }, 
      map { 'from': 32, 'to': 31 }, 
      map { 'from': 32, 'to': 33 }, 
      map { 'from': 31, 'to': 34 }, 
      map { 'from': 34, 'to': 35 }, 
      map { 'from': 34, 'to': 36 }"/>

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
