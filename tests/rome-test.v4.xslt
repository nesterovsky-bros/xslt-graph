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
  <xsl:import href="dijkstra-search.v4.xslt"/>  

  <xsl:template match="/">
    <xsl:variable name="g" as="map(*)" select="t:create-graph()"/>
    <xsl:variable name="source" as="xs:integer" select="1498"/>
    <xsl:variable name="target" as="xs:integer" select="351"/>
    <!--<xsl:variable name="target" as="xs:integer" select="2052"/>-->
    
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

  <!--
    Graph is taken from http://users.diag.uniroma1.it/challenge9/download.shtml
    from collection http://users.diag.uniroma1.it/challenge9/data/rome/rome99.gr
  -->
  <xsl:function name="t:create-graph" as="map(*)">
    <xsl:variable name="roads" as="map(*)*" select="
      for 
        $line in unparsed-text-lines('rome99.gr')[starts-with(., 'a ')]
      return
      let $values := tokenize($line) return
        map 
        { 
          'from': xs:integer($values[2]),
          'to': xs:integer($values[3]),
          'length': xs:integer($values[4])
        }"/>

    <xsl:variable name="vertices" as="xs:integer*"
      select="distinct-values($roads!(?from, ?to))"/>
    <!--<xsl:variable name="in-edges" as="map(*)" select="
      map:merge($roads!map { ?to : . }, map { 'duplicates': 'combine' })"/>-->
    <xsl:variable name="out-edges" as="map(*)" select="
      map:merge($roads!map { ?from : . }, map { 'duplicates': 'combine' })"/>

    <xsl:sequence select="
      map
      {
        'vertices': function() { $vertices }, 
        'edges': function() { $roads }, 
        'edge-value': function($edge as map(*)) { $edge?length },
        'edge-vertices': function($edge as map(*)) { $edge?from, $edge?to },
        'vertex-edges': function($vertex as xs:integer) { $out-edges($vertex) }
      }"/>
  </xsl:function>

</xsl:stylesheet>
