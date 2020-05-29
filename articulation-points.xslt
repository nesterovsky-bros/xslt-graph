<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:q="xslt:priority-queue:2020"
  xmlns:g="xslt:graph-api:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  exclude-result-prefixes="xs q g map array">

  <!--
    An algorithm to return Articulation Points of the graph.
    See
      https://en.wikipedia.org/wiki/Biconnected_component
      https://github.com/nesterovsky-bros/xslt-graph/wiki/Algorithm-for-Biconnected-components.
      
      $g - a graph to traverse.      
      Returns a sequence of Articulation Points.
  -->
  <xsl:function name="g:articulation-points" as="item()*">
    <xsl:param name="g" as="map(*)"/>

    <xsl:iterate select="g:edges($g)!(1 to 4)">
      <xsl:param name="stack" as="array(map(*))" select="[]"/>
      <xsl:param name="state" as="xs:integer" select="0"/>
      <xsl:param name="visited" as="map(*)" select="map {}"/>
      <xsl:param name="index" as="xs:integer" select="0"/>
      <xsl:param name="vertex" as="item()" select="head(g:vertices($g))"/>
      <xsl:param name="parent" as="item()?"/>
      <xsl:param name="result" as="xs:integer" select="0"/>
      <xsl:param name="articulation" as="xs:integer" select="-1"/>
      <xsl:param name="vertices" as="item()*"/>

      <xsl:choose>
        <xsl:when test="$state = 0">
          <xsl:variable name="index" as="xs:integer" select="$index + 1"/>

          <xsl:next-iteration>
            <xsl:with-param name="state" select="1"/>
            <xsl:with-param name="index" select="$index"/>
            <xsl:with-param name="visited" 
              select="map:put($visited, $vertex, $index)"/>
            <xsl:with-param name="result" select="$index"/>
            <xsl:with-param name="articulation" select="$articulation"/>
            <xsl:with-param name="vertices" select="
              g:vertex-edges($vertex, $g)!
                g:edge-vertices(., $g)[not(. = ($parent, $vertex))]"/>
          </xsl:next-iteration>  
        </xsl:when>
        <xsl:when test="exists($vertices)">
          <xsl:variable name="next" as="item()" select="head($vertices)"/>
          <xsl:variable name="vertices" as="item()*" select="tail($vertices)"/>
          <xsl:variable name="next-index" as="xs:integer?" 
            select="$visited($next)"/>

          <xsl:choose>
            <xsl:when test="exists($next-index)">
              <xsl:variable name="result" as="xs:integer" select="
                if ($next-index lt $result) then
                  $next-index
                else
                  $result"/>

              <xsl:next-iteration>
                <xsl:with-param name="result" select="$result"/>
                <xsl:with-param name="vertices" select="$vertices"/>
              </xsl:next-iteration>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="frame" as="map(*)" select="
                map
                {
                  'vertex': $vertex,
                  'parent': $parent,
                  'result': $result,
                  'articulation': $articulation,
                  'vertices': $vertices
                }"/>

              <xsl:next-iteration>
                <xsl:with-param name="stack" 
                  select="array:insert-before($stack, 1, $frame)"/>
                <xsl:with-param name="state" select="0"/>
                <xsl:with-param name="vertex" select="$next"/>
                <xsl:with-param name="parent" select="$vertex"/>
                <xsl:with-param name="articulation" select="0"/>
              </xsl:next-iteration>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$articulation gt 0">
            <xsl:sequence select="$vertex"/>
          </xsl:if>

          <xsl:choose>
            <xsl:when test="array:size($stack) = 0">
              <xsl:break/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="frame" as="map(*)"
                select="array:head($stack)"/>
              <xsl:variable name="vertex" as="item()" select="$frame?vertex"/>
              <xsl:variable name="vertex-index" as="xs:integer?"
                select="$visited($vertex)"/>

              <xsl:variable name="articulation" as="xs:integer" select="
                if ($result ge $vertex-index) then
                  $frame?articulation + 1
                else
                  $frame?articulation"/>

              <xsl:variable name="result" as="xs:integer" select="
                if ($frame?result lt $result) then
                  $frame?result
                else
                  $result"/>

              <xsl:next-iteration>
                <xsl:with-param name="stack" select="array:tail($stack)"/>
                <xsl:with-param name="vertex" select="$vertex"/>
                <xsl:with-param name="parent" select="$frame?parent"/>
                <xsl:with-param name="vertices" select="$frame?vertices"/>
                <xsl:with-param name="result" select="$result"/>
                <xsl:with-param name="articulation" select="$articulation"/>
              </xsl:next-iteration>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:iterate>
  </xsl:function>

</xsl:stylesheet>
