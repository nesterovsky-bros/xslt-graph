<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:q="xslt:priority-queue:2020"
  xmlns:g="xslt:graph-api:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  exclude-result-prefixes="xs q g map array">

  <!--
    An algorithm to return Biconnected conponents of connected graph.
    See
      https://en.wikipedia.org/wiki/Biconnected_component
      https://github.com/nesterovsky-bros/xslt-graph/wiki/Algorithm-for-Biconnected-components.
      
      $g - a graph to traverse.      
      Returns a sequence of of arrays, where each array denotes a biconnected subgraph.
  -->
  <xsl:function name="g:biconnected-components" as="array(*)*">
    <xsl:param name="g" as="map(*)"/>

    <xsl:sequence select="g:biconnected-components(head(g:vertices($g)), $g)"/>
  </xsl:function>
  
  <!--
    An algorithm to return Biconnected conponents of connected graph.
    See
      https://en.wikipedia.org/wiki/Biconnected_component
      https://github.com/nesterovsky-bros/xslt-graph/wiki/Algorithm-for-Biconnected-components.
      
      $vertex - an initial vertex.
      $g - a graph to traverse.      
      Returns a sequence of of arrays, where each array denotes a biconnected subgraph.
  -->
  <xsl:function name="g:biconnected-components" as="array(*)*">
    <xsl:param name="vertex" as="item()"/>
    <xsl:param name="g" as="map(*)"/>

    <xsl:iterate select="g:edges($g)!(1 to 4), 1, 2">
      <xsl:param name="stack" as="array(map(*))" select="[]"/>
      <xsl:param name="state" as="xs:integer" select="0"/>
      <xsl:param name="visited" as="map(*)" select="map {}"/>
      <xsl:param name="index" as="xs:integer" select="0"/>
      <xsl:param name="vertex" as="item()" select="$vertex"/>
      <xsl:param name="parent" as="item()?"/>
      <xsl:param name="result-index" as="xs:integer" select="0"/>
      <xsl:param name="result-component" as="array(*)" select="[]"/>
      <xsl:param name="vertices" as="item()*"/>

      <xsl:choose>
        <xsl:when test="$state = 0">
          <xsl:variable name="index" as="xs:integer" select="$index + 1"/>
          
          <xsl:variable name="vertices" as="item()*" select="
            g:vertex-edges($vertex, $g)!
              g:edge-vertices(., $g)[not(. = ($parent, $vertex))]"/>

          <xsl:next-iteration>
            <xsl:with-param name="state" select="1"/>
            <xsl:with-param name="index" select="$index"/>
            <xsl:with-param name="visited"
              select="map:put($visited, $vertex, $index)"/>
            <xsl:with-param name="result-index" select="$index"/>
            <xsl:with-param name="result-component" select="[$vertex]"/>
            <xsl:with-param name="vertices" select="$vertices"/>
          </xsl:next-iteration>
        </xsl:when>
        <xsl:when test="exists($vertices)">
          <xsl:variable name="next" as="item()" select="head($vertices)"/>
          <xsl:variable name="vertices" as="item()*" select="tail($vertices)"/>
          <xsl:variable name="next-index" as="xs:integer?" 
            select="$visited($next)"/>

          <xsl:choose>
            <xsl:when test="exists($next-index)">
              <xsl:variable name="result-index" as="xs:integer" select="
                if ($next-index lt $result-index) then
                  $next-index
                else
                  $result-index"/>

              <xsl:next-iteration>
                <xsl:with-param name="result-index" select="$result-index"/>
                <xsl:with-param name="vertices" select="$vertices"/>
              </xsl:next-iteration>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="frame" as="map(*)" select="
                map
                {
                  'vertex': $vertex,
                  'parent': $parent,
                  'index': $result-index,
                  'component': $result-component,
                  'vertices': $vertices
                }"/>

              <xsl:next-iteration>
                <xsl:with-param name="stack"
                  select="array:insert-before($stack, 1, $frame)"/>
                <xsl:with-param name="state" select="0"/>
                <xsl:with-param name="vertex" select="$next"/>
                <xsl:with-param name="parent" select="$vertex"/>
              </xsl:next-iteration>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="array:size($stack) = 0">
              <xsl:break select="[$vertex][$index = 1]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="frame" as="map(*)"
                select="array:head($stack)"/>
              <xsl:variable name="vertex" as="item()" select="$frame?vertex"/>
              <xsl:variable name="vertex-index" as="xs:integer?"
                select="$visited($vertex)"/>
              <xsl:variable name="frame-index" as="xs:integer"
                select="$frame?index"/>
              <xsl:variable name="frame-component" as="array(*)"
                select="$frame?component"/>

              <xsl:if test="$result-index ge $vertex-index">
                <xsl:sequence 
                  select="array:append($result-component, $vertex)"/>
              </xsl:if>

              <xsl:variable name="result-component" as="array(*)" select="
                if ($result-index ge $vertex-index) then
                  $frame-component
                else
                  array:join(($result-component, $frame-component))"/>

              <xsl:variable name="result-index" as="xs:integer" select="
                if ($frame-index lt $result-index) then
                  $frame-index
                else
                  $result-index"/>
              
              <xsl:next-iteration>
                <xsl:with-param name="stack" select="array:tail($stack)"/>
                <xsl:with-param name="vertex" select="$vertex"/>
                <xsl:with-param name="parent" select="$frame?parent"/>
                <xsl:with-param name="vertices" select="$frame?vertices"/>
                <xsl:with-param name="result-index" select="$result-index"/>
                <xsl:with-param name="result-component" 
                  select="$result-component"/>
              </xsl:next-iteration>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:iterate>
  </xsl:function>

</xsl:stylesheet>
