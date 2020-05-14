<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:g="xslt:graph-api:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  xmlns:t="public:this"
  exclude-result-prefixes="xs g map array t">

  <xsl:import href="../graph.xslt"/>
  <xsl:import href="../search.xslt"/>
  <xsl:import href="../topological-sort.xslt"/>

  <xsl:template match="/">
    <xsl:variable name="g" as="map(*)" select="t:create-graph()"/>

    <xsl:message>
      <xsl:text>Topological sort:
</xsl:text>

      <xsl:value-of select="g:topological-sort($g)" separator=" "/>
    </xsl:message>
  </xsl:template>

  <xsl:function name="t:create-graph" as="map(*)">
    <xsl:variable name="edges" as="map(*)*" select="
      map { 'from': 5, 'to': 11 }, 
      map { 'from': 7, 'to': 11 }, 
      map { 'from': 7, 'to': 8 }, 
      map { 'from': 3, 'to': 8 }, 
      map { 'from': 3, 'to': 10 }, 
      map { 'from': 11, 'to': 2 }, 
      map { 'from': 11, 'to': 9 }, 
      map { 'from': 11, 'to': 10 }, 
      map { 'from': 8, 'to': 9 }"/>

    <xsl:variable name="vertices" as="map(*)" select="
      map:merge
      (
        $edges!(map { ?from : . }),
        map { 'duplicates': 'combine' }
      )"/>

    <xsl:sequence select="
      map
      {
        'vertices': function() { map:keys($vertices) }, 
        'edges': function() { $edges }, 
        'edge-vertices': function($edge as map(*)) as xs:integer+ { $edge?from, $edge?to }, 
        'vertex-edges': function($vertex as xs:integer) as map(*)* { $vertices($vertex) }
      }"/>
  </xsl:function>

</xsl:stylesheet>
