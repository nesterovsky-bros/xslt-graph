<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:g="xslt:graph-api:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  xmlns:t="public:this"
  exclude-result-prefixes="xs g map array t">

  <xsl:import href="../graph.xslt"/>
  <xsl:import href="../depth-first-search.xslt"/>

  <xsl:template match="/">
    <xsl:variable name="g" as="map(*)" select="t:create-routes()"/>
    <xsl:variable name="root" as="xs:string" select="'Frankfürt'"/>

    <xsl:message>
      <xsl:for-each select="g:depth-first-search($root, $g)">
        <xsl:value-of separator="" select="
          string-join((for $i in 1 to ?depth return '  '), ''),
          ?from!(., ' - '), ?to, 
          ?edge!(': ', g:edge-value(., $g))"/>
        
        <xsl:text>
</xsl:text>
      </xsl:for-each>
    </xsl:message>
  </xsl:template>

  <xsl:function name="t:create-routes" as="map(*)">
    <xsl:variable name="routes" as="map(*)*" select="
      map { 'from': 'Frankfürt', 'to': 'Mannheim', 'km': 85 }, 
      map { 'from': 'Frankfürt', 'to': 'Würzburg', 'km': 217 },
      map { 'from': 'Frankfürt', 'to': 'Kassel', 'km': 173 }, 
      map { 'from': 'Mannheim', 'to': 'Karlsruhe', 'km': 80 },
      map { 'from': 'Karlsruhe', 'to': 'Augsburg', 'km': 250 }, 
      map { 'from': 'Augsburg', 'to': 'München', 'km': 84 },
      map { 'from': 'Würzburg', 'to': 'Erfurt', 'km': 186 }, 
      map { 'from': 'Würzburg', 'to': 'Nürnberg', 'km': 103 },
      map { 'from': 'Nürnberg', 'to': 'Stuttgart', 'km': 183 }, 
      map { 'from': 'Nürnberg', 'to': 'München', 'km': 167 },
      map { 'from': 'Kassel', 'to': 'München', 'km': 502 }"/>

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
        'edge-value': function($edge as map(*)) as xs:integer* { $edge?km },
        'edge-vertices': function($edge as map(*)) as xs:string+ { $edge?from, $edge?to }, 
        'vertex-edges': function($vertex as xs:string) as map(*)* { $vertices($vertex) }
      }"/>
  </xsl:function>

</xsl:stylesheet>
