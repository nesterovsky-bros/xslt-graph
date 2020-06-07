<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:g="xslt:graph-api:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  exclude-result-prefixes="xs g map array">

  <!--
    Collects connected components.
    See https://en.wikipedia.org/wiki/Component_(graph_theory).

      $g - a graph to traverse.
      Returns a sequence of arrays, 
        where each array is vertices of a connected component.
  -->
  <xsl:function name="g:connected-components" as="array(*)*">
    <xsl:param name="g" as="map(*)"/>

    <xsl:variable name="vertices" as="item()*" select="g:vertices($g)"/>

    <xsl:iterate select="$vertices">
      <xsl:param name="visited" as="map(*)" select="map {}"/>

      <xsl:variable name="vertex" as="item()" select="."/>

      <xsl:choose>
        <xsl:when test="map:contains($visited, $vertex)">
          <xsl:next-iteration/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="next" as="item()+">
            <xsl:iterate select="$vertices">
              <xsl:param name="queue" as="array(*)" select="[$vertex]"/>
              <xsl:param name="visited" as="map(*)" select="$visited"/>

              <xsl:choose>
                <xsl:when test="array:size($queue) eq 0">
                  <xsl:break select="$visited"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="item" as="item()" 
                    select="array:head($queue)"/>
                  <xsl:variable name="queue" as="array(*)" 
                    select="array:tail($queue)"/>

                  <xsl:choose>
                    <xsl:when test="$visited($item)">
                      <xsl:next-iteration>
                        <xsl:with-param name="queue" select="$queue"/>
                      </xsl:next-iteration>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:sequence select="$item"/>

                      <xsl:variable name="visited" as="map(*)"
                        select="map:put($visited, $item, true())"/>

                      <xsl:variable name="items" as="array(*)" select="
                        array 
                        {
                          for 
                            $edge in g:vertex-edges($item, $g),
                            $vertex in g:edge-vertices($edge, $g)
                          return
                            $vertex[not(map:contains($visited, $vertex))]
                        }"/>

                      <xsl:next-iteration>
                        <xsl:with-param name="queue" 
                          select="array:join(($items, $queue))"/>
                        <xsl:with-param name="visited" select="$visited"/>
                      </xsl:next-iteration>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:iterate>
          </xsl:variable>

          <xsl:variable name="vertices" as="item()+"
            select="$next[position() lt last()]"/>
          <xsl:variable name="visited" as="map(*)"
            select="$next[last()]"/>

          <xsl:sequence select="array { $vertices }"/>

          <xsl:next-iteration>
            <xsl:with-param name="visited" select="$visited"/>
          </xsl:next-iteration>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:iterate>
  </xsl:function>

</xsl:stylesheet>